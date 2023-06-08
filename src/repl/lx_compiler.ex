#### Execute on iex to contnue
### iex(1)> c("lx_compiler.ex")
### iex(2)> Lx.eval("1+1+5-5/4") |> Lx.eval_forms()
### TODO: convert all elixir clauses on erlang directly


####
defmodule Lx do
  require Record
  Record.defrecord(:elixir_ex,
      caller: false,
      prematch: :warn,
      stacktrace: false,
      unused: {%{}, 0},
      vars: {%{}, false}
      )
  Record.defrecord(:elixir_erl,
      context: nil,
      extra: nil,
      caller: false,
      var_names: %{},
      extra_guards: [],
      counter: %{},
      expand_captures: false,
      stacktrace: nil
      )
  # TODO: create a genserver for configurations
  # defmodule Config do
  #   def get(key) do
  #     [{_, value}] = :ets.lookup(__MODULE__, key)
  #     value
  #   end
  # end
  defmodule Local do
    def if_tracker(module, callback), do: if_tracker(module, :ok, callback)
    def if_tracker(module, default, callback) do
      try do
        # {dataset, _} = tables = :elixir_module.data_tables(module)
        # case {:ets.member(dataset, {:elixir, :locals}), tables} do
        #   {true, tracker} -> callback.(tracker)
        #   {false, _} -> default
        # end
        default
      catch
        _ -> default
      end
    end
    def record_local(_tuple, _module, nil, _meta, _is_macro_dispatch), do: :ok
    def record_local(tuple, module, function, meta, is_macro_dispatch) do
      if_tracker(module, fn tracker ->
        Elixir.Module.LocalsTracker.add_local(tracker, function, tuple, meta, is_macro_dispatch)
        :ok
      end)
    end
    def record_import(_tuple, receiver, module, function) when is_nil(function) and module == receiver, do: false
    def record_import(tuple, receiver, module, function) do
      if_tracker(module,
        fn tracker ->
          Elixir.Module.LocalsTracker.add_import(tracker, function, receiver, tuple)
        :ok
      end)
    end
  end

  defmodule Expand do
    alias Lx.Env
    require Lx
    def check_deprecated(_,_, :erlang, _, _, _), do: :ok
    def check_deprecated(_,_, :elixir_def, _, _, _), do: :ok
    def check_deprecated(_,_, :elixir_module, _, _, _), do: :ok
    def check_deprecated(_,_, Elixir.Kernel, _, _, _), do: :ok
    def check_deprecated(meta, kind, Elixir.Application, name, arity, e) do
      case e do
        %{module: module, function: nil} when module != nil or (kind == :macro and name == :get_env) or name == :fetch_env or name == :fetch_env! ->
          :elixir_errors.form_warn(meta, e, __MODULE__, {:compile_env, name, arity})
        _ -> :ok
      end
    end
    def check_deprecated(meta, kind, receiver, name, arity, e) do
      ## Any compile time behaviour cannot be verified by the runtime group pass
      case ((:maps.get(:function, e) == nil or kind == :macro)) and get_deprecations(receiver) do
        [_ | _] = deprecations ->
          case :lists.keyfind({name, arity}, 1, deprecations) do
            {_, message} ->
              :elixir_errors.form_warn(meta, e, __MODULE__, {:deprecated, receiver, name, arity, message})
            _ -> false
          end
        _ -> :ok
      end
    end
    def get_deprecations(receiver) do
      case :code.ensure_loaded(receiver) do
        {:module, receiver} -> get_info(receiver, :deprecated)
        _ -> []
      end
    end
    def get_info(receiver, key) do
      if :erlang.function_exported(receiver, :__info__, 1) do
          try do
            apply(receiver, :__info__, [key])
          catch
            _ -> []
          end
        else
          []
        end
    end
    def is_import(meta, arity) do
      case :lists.keyfind(:imports, 1, meta) do
        {:imports, imports} ->
          case :lists.keyfind(:context, 1, meta) do
            {:context, _} ->
              case :lists.keyfind(:context, 1, meta) do
                {arity, receiver} -> {:import, receiver}
                false -> false
              end
            false -> false
          end
        false -> false
      end
    end
    def find_import_by_name_arity(meta, {_name, arity} = tuple, extra, e) do
      case is_import(meta, arity) do
        {:import, _} = import_ ->
          import_
        false ->
          funcs = :maps.get(:functions, e)
          macs = extra ++ :maps.get(:macros, e)
          fun_match = find_import_by_name_arity(tuple, funcs)
          mac_match = find_import_by_name_arity(tuple, macs)

          case {fun_match, mac_match} do
            {[], [receiver]} -> {:macro, receiver}
            {[receiver], []} -> {:function, receiver}
            {[],[]} -> false
            _ ->
              {name, arity} = tuple
              [first, second | _] = fun_match ++ mac_match
              error = {:ambiguous_call, {first, second, name, arity}}
              :elixir_errors.form_error(meta, e, __MODULE__, error)
          end
      end
    end
    def find_import_by_name_arity(tuple, list) do
      for {receiver, set} <- list, :ordsets.is_element(tuple, set), do: receiver
    end
    def dispatch_import(meta, name, args, s, e, callback) do
      arity = length(args)
      case expand_import(meta, {name, arity}, args, s, e, [], false) do
        {:ok, receiver, quoted} ->
          expand_quoted(meta, receiver, name, arity, quoted, s, e)
        {:ok, receiver, new_name, new_args} ->
          expand({{:., meta, [receiver, new_name]}, meta, new_args}, s, e)
        :error -> callback.()
      end
    end
    def expand_import(meta, {name, arity} = tuple, args, s, e, extra, external) do
      module = :maps.get(:module, e)
      function = :maps.get(:function, e)
      dispatch = find_import_by_name_arity(meta, tuple, extra, e)
      case dispatch do
        {:import, _} ->
          do_expand_import(meta, tuple, args, module, s, e, dispatch)
        _ ->
          allows_local = external || (function != nil and function != tuple)
          local = allows_local and :elixir_def.local_for(meta, name, arity, [:defmacro, :defmacrop], e)
          case dispatch do
            {_, receiver} when local != false and receiver != module ->
              ## The is a local and an import. This is a conflict unless
              ## the receiver is the same as module (happens on bootstrap)
              error = {:macro_conflict, {receiver, name, arity}}
              :elixir_errors.form_error(meta, e, __MODULE__, error)

              ## There is no local. Dispatch the import.
              _ when local == false ->
                do_expand_import(meta, tuple, args, module, s, e, dispatch)
              ## Dispatch to the local
              _ ->
                Env.trace({:local_macro, meta, name, arity}, e)
                Local.record_local(tuple, module, function, meta, true)
                {:ok, module, expand_macro_fun(meta, local, module, name, args, s, e)}
          end
      end
    end
    def do_expand_import(meta, {name, arity} = tuple, args, module, s, e, result) do
      case result do
        {:function, receiver} ->
          Env.trace({:imported_function, meta, receiver, name, arity}, e)
          Local.record_import(tuple, receiver, module, :maps.get(:function, e))
          {:ok, receiver, name, args}
        {:macro, receiver} ->
          check_deprecated(meta, :macro, receiver, name, arity, e)
          Local.record_import(tuple, receiver, module, :maps.get(:function, e))
          {:ok, receiver, expand_macro_named(meta, receiver, name, arity, args, s, e)}
        {:import, receiver} ->
          case expand_require([{:required, true}|meta], receiver, tuple, args, s, e) do
            {:ok, _, _} = response -> response
            :error -> {:ok, receiver, name, args}
          end
        false when module == Elixir.Kernel ->
          case :elixir_rewrite.inline(module, name, arity) do
            {ar, an} -> {:ok, ar, an, args}
            false -> :error
          end
        false -> :error
      end
    end
    def required(meta) do
      :lists.keyfind(:required, 1, meta) == {:required, true}
    end
    def expand_require(meta, receiver, {name, arity} = tuple, args, s, e) do
      required = (receiver == :maps.get(:module, e) || required(meta) || :ordsets.is_element(receiver, :maps.get(:requires, e)))

      if is_macro(tuple, receiver, required) do
        check_deprecated(meta, :macro, receiver, name, arity, e)
        Env.trace({:remote_macro, meta, receiver, name, arity}, e)
        {:ok, receiver, expand_macro_named(meta, receiver, name, arity, args, s, e)}
      else
        check_deprecated(meta, :function, receiver, name, arity, e)
        :error
      end
    end
    ### instropection
    def is_macro(_tuple, _module, false), do: false
    def is_macro(tuple, receiver, true) do
      try do
        macros = apply(receiver, :__info__, [:macros])
        :ordsets.is_element(tuple, macros)
      rescue
        _ -> false
      end
    end
    def prune_stacktrace([{_, _, [e | _], _} | _], _mfa, info, {:ok, e}), do: info
    def prune_stacktrace([{m, f, a, _} | _], {m, f, a}, info, _e), do: info
    def prune_stacktrace([{mod, _, _, _} | _], _mfa, info, _e) when mod in [:elixir_dispatch,:elixir_exp], do: info
    def prune_stacktrace([h | t], mfa, info, e),
      do: [ h | prune_stacktrace(t, mfa, info, e)]
    def prune_stacktrace([], _mfa, info, _e), do: info

    def expand_macro_fun(meta, fun, receiver, name, args, s, e) do
      line = :maps.get(:line, meta)
      earg = {line, s, e}
      try do
        apply(fun, [earg | args])
      rescue
        _ ->
          kind = ""
          reason = ""
          arity = length(args)
          mfa = {receiver, :elixir_utils.macro_name(name), arity+1}
          info = [{receiver, name, arity, [{:file, "expanding macro"}]}, caller(line, e)]
          :erlang.raise(kind, reason, prune_stacktrace(__STACKTRACE__, mfa, info, {:ok, earg}))
      end
    end
    def expand_macro_named(meta, receiver, name, arity, args, s, e) do
      proper_name = :elixir_utils.macro_name(name)
      proper_arity = arity + 1
      #fun = fn x -> appply(receiver, proper_name, ..proper_arity)
      fun = fn _ -> 1 end
      expand_macro_fun(meta, fun, receiver, name, args, s, e)
    end
    def expand_quoted(meta, receiver, name, arity, quoted, s, e) do
      next = :elixir_module.next_counter(:maps.get(:module, e))
      try do
        to_expand = :elixir_quote.linify_with_context_counter(meta, {receiver, next}, quoted)
        expand(to_expand, s, e)
      rescue
        re ->
          kind = ""
          reason = ""
          mfa = {receiver, :elixir_utils.macro_name(name), arity+1}
          info = [{receiver, name, arity, [{:file, "expanding macro"}]}, caller(:maps.get(:line, meta), e)]
          :erlang.raise(kind, reason, prune_stacktrace(__STACKTRACE__, mfa, info, :error))
      end
    end
    def caller(line, e) do
      :elixir_utils.caller(line, :maps.get(:file, e), :maps.get(:module, e), :maps.get(:function, e))
    end
    def expand_arg(arg, acc, e) when is_number(arg) or is_atom(arg) or is_binary(arg) or is_pid(arg), do: {arg, acc, e}
    def expand_arg(arg, {acc, s}, e) do
      {earg, sacc, eacc} = expand(arg, Env.reset_read(acc, s), e)
      {earg, {sacc, s}, eacc}
    end
    def expand_args([arg], s, e) do
      {earg, se, ee} = expand(arg, s, e)
      {[earg], se, ee}
    end
    def expand_args(args, s, %{context: :match} = e) do
      mapfold(&expand/3, s, e, args)
    end
    def expand_args(args, s, e) do
      {eargs, {sa, _}, ea} = mapfold(&expand_arg/3,
      {Env.prepare_write(s), s}, e, args)
      {eargs, Env.close_write(sa, s), ea}
    end
    def format_error(_), do: :ok
    def file_error(_, _, _, _), do: :ok
    def form_error(_, _, _, _), do: :ok
    def module_error(_, _, _, _), do: :ok
    def guard_context(%{prematch: {_, _, {:bitsize, _}}}), do: "bitstring size specifier"
    def guard_context(_), do: "guards"


    defp expand_local(meta, name, args, s, %{module: module, function: function, context: context} = e) when function != nil do
      assert_no_clauses(name, meta, args, e)

      ## In case we have the wrong context, we log a module error
      ## so we can print multiple entries at the same time

      case context do
        :match ->
          module_error(meta, e, __MODULE__, {:invalid_local_invocation, :match, {name,meta, args}})
        :guard ->
          module_error(meta, e, __MODULE__, {:invalid_local_invocation, guard_context(s), {name,meta, args}})
        nil ->
          arity = length(args)
          Env.trace({:local_function, meta, name, arity, e})
          Local.record_local({name, arity}, module, function, meta, false)
      end
      {eargs, sa, ea} = expand_args(args, s, e)
      {{name, meta, eargs}, sa, ea}
    end
    defp expand_local(meta, name, args, _s, %{function: nil} = e) do
      file_error(meta, e, __MODULE__, {:undefined_function, name, args})
    end
    def match(fun, expr, after_s, _before_s, %{context: :match} = e) do
      fun.(expr, after_s, e)
    end
    def match(fun, expr, after_s, before_s, e) do
      after_s_ = Lx.elixir_ex(after_s)
      current = after_s_[:vars]
      {_, counter} = unused = after_s_[:unused]

      before_s_ = Lx.elixir_ex(before_s)
      {read, _} = before_s_[:vars]
      prematch = before_s_[:prematch]

      call_s = Lx.elixir_ex(before_s,
          prematch: {read, counter},
          unused: unused,
          vars: current
        )
      call_e = %{e | context: :match}
      {eexpr, eex, ee} = fun.(expr, call_s, call_e)
      eex_ = Lx.elixir_ex(eex)
      new_current = eex_[:vars]
      new_unused = eex_[:unused]

      end_s = Lx.elixir_ex(after_s,
                    prematch: prematch,
                    unused: new_unused,
                    vars: new_current)
      end_e = %{ee | context: :maps.get(:context, e)}
      {eexpr, end_s, end_e}
    end
    def expand({:=, meta, [left, right]}, s, e) do
      assert_no_guard_scope(meta, "=", s, e)
      {e_right, sr, er} = expand(right, s, e)
      {e_left, sl, el} = match(&expand/3, left, sr, s, er)
      {{:=, meta, [e_left, e_right]}, sl, el}
    end
    ## Local calls
    def expand({atom, meta, args}, s, e) when is_atom(atom) and is_list(meta) and is_list(args) do
      assert_no_ambiguous_op(atom, meta, args, s, e)
      dispatch_import(meta, atom, args, s, e, fn ->
        expand_local(meta, atom, args, s, e)
      end)
    end
    ## Remote calls
    def expand({{:".", dot_meta, [left, right]}, meta, args}, s, e) when is_tuple(left) or (is_atom(left) and is_list(meta) and is_list(args)) do
      {e_left, sl, el} = expand(left, :elixir_env.prepare_write(s), e)
      :elixir_dispatch.dispatch_require(meta, e_left, right, args, s, el, fn (ar, af, aa) ->
        expand_remote(ar, dot_meta, af, meta, aa, s, sl, el)
      end)
    end
    ##  anonymous call
    def expand({{:".", dot_meta, [expr]}, meta, args}, s, e) when is_list(args) do
      assert_no_match_or_guard_scope(meta, "anonymous call", s, e)
      case expand_args([expr | args], s, e) do
        {[eexpr | _], _, _} when is_atom(eexpr) ->
          form_error(meta, e, __MODULE__, {:invalid_function_call, eexpr})
        {[eexpr | eargs], sa, ea} ->
          {{{:".", dot_meta, [eexpr]}, meta, eargs}, sa, ea}
      end
    end



    def expand({left, right}, s, e) do
      expand_args([left, right], s, e)
    end
    def expand(list, s, %{context: :match} = e) when is_list(list) do
      expand_list(list, &expand/3, s, e, [])
    end
    def expand(list, s, e) when is_list(list) do
      {eargs, {se, _}, ee} = expand_list(list, &expand_arg/3, {Env.preparwe_write(s), s}, e, [])
      {eargs, Env.close_write(se,s), ee}
    end
    def expand(function, s, e) when is_function(function) do
      if :erlang.fun_info(function, :type) == {:type, :external} and :erlang.fun_info(function, :env) == {:env, []} do
        :elixir_quote.fun_to_quote(function, s, e)
      else
        form_error([{:line, 0}], :maps.get(:file, e), __MODULE__, {:invalid_quoted_expr, function})
      end
    end
    def expand(other, s, e) when is_number(other) or is_atom(other) or is_binary(other) do
      {other, s, e}
    end
    def expand(other, _s, e) do
      form_error([{:line, 0}], :maps.get(:file, e), __MODULE__, {:invalid_quoted_expr, other})
    end

    def expand_list([{'|', meta, [_,_] = args}], fun, s, e, list) do
      {eargs, sacc, eacc} = mapfold(fun, s, e, args)
      expand_list([], fun, sacc, eacc, [{'|', meta, eargs} | list])
    end
    def expand_list([h|t], fun, s, e, list) do
      {eargs, sacc, eacc} = fun.(h, s, e)
      expand_list(t, fun, sacc, eacc, [eargs|list])
    end
    def expand_list([], _fun, s, e, list) do
      {:lists.reverse(list), s, e}
    end

    ## Expand remote
    def expand_remote(receiver, dot_meta, right, meta, args, s, sl, %{context: context} = e) when is_atom(receiver) or is_tuple(receiver) do
      assert_no_clauses(right, meta, args, e)
      case {context, :lists.keyfind(:no_parens, 1, meta)} do
        {:guard, {:no_parens, true}} when is_tuple(receiver) ->
          {{{:'.', dot_meta, [receiver, right], meta, []}, sl, e}}
        {:guard, _} when is_tuple(receiver) ->
          form_error(meta, e, __MODULE__, {:parens_map_lookup, receiver, right, guard_context(s)})
        _ ->
          attached_dot_meta = attach_context_module(receiver, dot_meta, e)
          :erlang.is_atom(receiver) and Env.trace({:remove_function, meta, receiver, right, length(args)}, e)
          {eargs, {sa, _}, ea} = mapfold(&expand_arg/3, {sl, s}, e, args)
          case rewrite(context, receiver, attached_dot_meta, right, meta, eargs, s) do
            {:ok, rewritten} ->
              maybe_warn_comparison(rewritten, args, e)
              {rewritten, Env.close_write(sa, s), ea}
            {:error, error} ->
              form_error(meta, e, :elixir_rewrite, error)
          end
      end
    end
    def expand_remote(receiver, dot_meta, right, meta, args, _, _, e) do
      call = {{:".", dot_meta, [receiver, right]}, meta, args}
      form_error(meta, e, __MODULE__, {:elixir_rewrite, call})
    end
    def rewrite(:match, receiver, dot_meta, right, meta, eargs, _s),
      do: :elixir_rewrite.match_rewrite(receiver, dot_meta, right, meta, eargs)
    def rewrite(:guard, receiver, dot_meta, right, meta, eargs, s),
      do: :elixir_rewrite.guard_rewrite(receiver, dot_meta, right, meta, eargs, guard_context(s))
    def rewrite(_, receiver, dot_meta, right, meta, eargs, _s) do
      {:ok, :elixir_rewrite.rewrite(receiver, dot_meta, right, meta, eargs)}
    end

    defp maybe_warn_comparison({{:".", _,  [:erlang, op]}, meta, [eleft, eright]}, [left, right], e) when op in ~w(> < =< >= min max)a do
      case is_struct_comparison(eleft, eright, left, right) do
        false ->
          case is_nested_comparison(op, eleft, eright, left, right) do
           false -> :ok
           comp_expr ->
              :elixir_errors.form_warn(meta, e, __MODULE__, {:nested_comparison, comp_expr})
          end
        struct_expr ->
          :elixir_errors.form_warn(meta, e, __MODULE__, {:struct_comparison, struct_expr})
      end
    end
    defp maybe_warn_comparison(_,_,_), do: :ok

    defp is_struct_comparison(eleft, eright, left, right) do
      if is_struct_expression(eleft) do
        left
      else
        if is_struct_expression(eright) do
          right
        else
          false
        end
      end
    end

    defp is_struct_expression({:"%", _, [struct, _]}) when is_atom(struct), do: true
    defp is_struct_expression({:"%{}", _, kvs}) do
      case  :lists.keyfind(:__struct__, 1, kvs) do
        {:__struct__, struct} when is_atom(struct) -> true
        _ -> false
      end
    end
    defp is_struct_expression(_other), do: false

    def is_nested_comparison(op, eleft, eright, left, right) do
      nested_expr = {:elixir_utils.erlang_comparison_op_to_elixir(op), [], [left, right]}
      if is_comparison_expression(eleft) do
        nested_expr
      else
        if is_comparison_expression(eright) do
          nested_expr
        else
          false
        end
      end
    end

    def is_comparison_expression({:".", _, [:erlang, op]}, _, _) when op in ~w(> < <= >=)a, do: true
    def is_comparison_expression(_other), do: false


    defp mapfold(fun, s, e, list), do: mapfold(fun, s, e, list, [])
    defp mapfold(fun, s, e, [h|t], acc) do
      {rh, rs, re} = fun.(h, s, e)
      mapfold(fun, rs, re, t, [rh|acc])
    end
    defp mapfold(_fun, s, e, [], acc),
      do: {:lists.reverse(acc), s, e}

    ## Compilation environment macros

    ###
    defp attach_context_module(_receiver, meta, %{function: nil}), do: meta
    defp attach_context_module(receiver, meta, %{context_modules: [ctx | _], module: mod}) when ctx == mod and receiver == mod, do: meta
    defp attach_context_module(receiver, meta, %{context_modules: context_modules}) do
      if :lists.member(receiver, context_modules) do
        [{:context_module, true} | meta]
      else
        meta
      end
    end

    defp assert_no_match_or_guard_scope(meta, kind, s, e) do
      assert_no_match_scope(meta, kind, e)
      assert_no_guard_scope(meta, kind, s, e)
    end

    defp assert_no_match_scope(meta, kind, %{context: :match, file: file}) do
      form_error(meta, file, __MODULE__, {:invalid_pattern_in_match, kind})
    end
    defp assert_no_match_scope(_meta, _kind, _e), do: []
    # defp assert_no_guard_scope(meta, kind, %{context: :match, file: file}) do
    #   file_error(meta, file, __MODULE__, {:invalid_pattern_in_match, kind})
    # end
    # defp assert_no_guard_scope(_meta, _kind, _e), do: :ok
    defp assert_no_guard_scope(meta, kind, _s, %{context: :guard, file: file}) do
      require Lx
      key =
        case Lx.elixir_ex(:prematch) do
          {_, _, {:bitsize, _}} -> :invalid_expr_in_bitsize
          _ -> :invalid_expr_in_guard
        end
      file_error(meta, file, __MODULE__, {key, kind})
    end
    defp assert_no_guard_scope(_meta, _kind, _s, _e), do: :ok

    defp assert_no_ambiguous_op(name, meta, [arg], s, e) do
      require Lx
      case :lists.keyfind(:ambiguous_op, 1, meta) do
        {:ambiguous_op, kind} ->
          pair = {name, kind}
          case Lx.elixir_ex(s, :vars) do
            {%{ ^pair => _ }, _} ->
              file_error(meta, e, __MODULE__, {:op_ambiguity, name, arg})
            _ -> :ok
          end
        _ -> :ok
      end
    end
    defp assert_no_ambiguous_op(_name, _meta, _args, _s, _e), do: :ok

    defp assert_no_clauses(_name, _meta, [], _e), do: :ok
    defp assert_no_clauses(name, meta, args, e) do
      assert_arg_with_no_clauses(name, meta, :lists.last(args), e)
    end
    defp assert_arg_with_no_clauses(name, meta, [{key, value} | rest], e) when is_atom(key) do
      case value do
        [{:'->', _, _}| _] ->
          file_error(meta, e, __MODULE__, {:invalid_clauses, name})
        _ ->
          assert_arg_with_no_clauses(name, meta, rest, e)
      end
    end
    defp assert_arg_with_no_clauses(_name, _meta, _arg, _e), do: :ok

  end
  defmodule Env do
    require Lx
    defstruct [
      module: nil,                                    # the current module
      file: "nofile",                                 # the current filename
      line: 1,                                        # the current line
      function: nil,                                  # the current function
      context: nil,                                   # can be match, guard or nil
      aliases: [],                                    # a list of aliases by new -> old names
      requires: :elixir_dispatch.default_requires(),  # a set with modules required
      functions: :elixir_dispatch.default_functions(),# a list with functions imported from modules
      macros: :elixir_dispatch.default_macros(),      # a list with macros imported from module
      macro_aliases: [],                              # keep aliases defined inside a macro
      context_modules: [],                            # modules defined in the current context
      versioned_vars: %{},                            # a map of vars with their latest versions
      lexical_tracker: nil,                           # lexical tracker PID
      tracers: []                                     # available compilation tracers
    ]
    def trace(_), do: :ok
    def trace(_, _), do: :ok

    def reset_read(s, _), do: s
    def prepare_write(s), do: s
    def close_write(s, _), do: s
    def env_for_eval(%{lexical_tracker: pid} = env) do
      new_env = %{ env | context: nil,
                         context_modules: [],
                         macro_aliases: [],
                         versioned_vars: %{}}

      if is_pid(pid) do
        if :erlang.is_process_alive(pid) do
          new_env
        else
          Elixir.IO.warn("an __ENV__ with outdated compilation information was given to eval,\ncall Macro.Env.prune_compile_info/1 to prune it")
          %{ new_env | lexical_tracker: nil, tracers: []}
        end
      else
        %{ new_env | tracers: []}
      end
    end
    def env_for_eval(opts) when is_list(opts) do
      env = %__MODULE__{}
      line =
        case :lists.keyfind(:line, 1, opts) do
          {:line, line_opt} when :erlang.is_integer(line_opt) -> line_opt
          _ -> :maps.get(:line, env)
        end
      file =
        case :lists.keyfind(:file, 1, opts) do
          {:file, file_opt} when :erlang.is_binary(file_opt) -> file_opt
          _ -> :maps.get(:file, env)
        end
      module =
        case :lists.keyfind(:module, 1, opts) do
          {:module, module_opt} when :erlang.is_atom(module_opt) -> module_opt
          _ -> nil
        end
      fa =
        case :lists.keyfind(:function, 1, opts) do
          {:function, {function, arity}} when :erlang.is_atom(function) and :erlang.is_integer(arity) -> {function, arity}
          {:function, nil} -> nil
          _ -> nil
        end
      temp_tracers =
        case :lists.keyfind(:tracers, 1, opts) do
          {:tracers, tracers_opt} when :erlang.is_list(tracers_opt) -> tracers_opt
          _ -> []
        end
      aliases =
        case :lists.keyfind(:aliases, 1, opts) do
          {:aliases, aliases_opt} when :erlang.is_list(aliases_opt) ->
            Elixir.IO.warn(":aliases option in eval is deprecated")
            aliases_opt
          _ -> []
        end

      requires =
        case :lists.keyfind(:requires, 1, opts) do
          {:requires, requires_opt} when :erlang.is_list(requires_opt) ->
            Elixir.IO.warn(":requires option in eval is deprecated")
            :ordsets.from_list(requires_opt);
          _ -> :maps.get(:requires, env)
        end
      functions =
        case :lists.keyfind(:functions, 1, opts) do
          {:functions, functions_opt} when :erlang.is_list(functions_opt) ->
            Elixir.IO.warn(":functions option in eval is deprecated")
            functions_opt
          _ -> :maps.get(:functions, env)
        end

      macros =
        case :lists.keyfind(:macros, 1, opts) do
          {:macros, macros_opt} when :erlang.is_list(macros_opt) ->
            Elixir.IO.warn(":macros option in eval is deprecated")
            macros_opt
          _ -> :maps.get(:macros, env)
        end

      {lexical_tracker, tracers} =
        case :lists.keyfind(:lexical_tracker, 1, opts) do
          {:lexical_tracker, pid} when :erlang.is_pid(pid) ->
            Elixir.IO.warn(":lexical_tracker option in eval is deprecated")
            if :erlang.is_process_alive(pid) do
              {pid, temp_tracers}
            else
              {nil, []}
            end
          {:lexical_tracker, nil} ->
            Elixir.IO.warn(":lexical_tracker option in eval is deprecated")
            {nil, []}
          _ -> {nil, temp_tracers}
        end
      %__MODULE__{
        file: file,
        module: module,
        function: fa,
        tracers: tracers,
        macros: macros,
        functions: functions,
        lexical_tracker: lexical_tracker,
        requires: requires,
        aliases: aliases,
        line: line
      }
    end

    def set_prematch_from_config(s) do
      Lx.elixir_ex(s, prematch: {%{}, 0, :none})
    end
    def env_to_ex(%{context: :match, versioned_vars: vars}) do
      counter = :erlang.map_size(vars)
      Lx.elixir_ex(prematch: {vars, counter, :none}, vars: {vars, false}, unused: {%{}, counter})
    end
    def env_to_ex(%{versioned_vars: vars}) do
      require Lx
      set_prematch_from_config(Lx.elixir_ex(vars: {vars, false}, unused: {%{}, :erlang.map_size(vars)}))
    end
  end
  def eval(str) when is_bitstring(str) do
    str = String.to_charlist(str)
    quoted = :elixir.string_to_quoted!(str, 1, 1, "nofile", [])
    {erls, _, _, _} = :elixir.quoted_to_erl(quoted, Env.env_for_eval([]))
    erls
  end

  def eval(ast) when is_tuple(ast) do
    {erls, _, _, _} = :elixir.quoted_to_erl(ast, Env.env_for_eval([]))
    erls
  end

  def eval_forms(forms) when is_tuple(forms) do
    {_, value, _} = :erl_eval.expr(forms, [])
    value
  end

  def quoted_to_erl(quoted, env) do
    {_, erls} = :elixir_erl_var.from_env(env)
    exs = Env.env_to_ex(env)
    quoted_to_erl(quoted, erls, exs, env)
  end

  def quoted_to_erl(quoted, erls, exs, env) do
    {exp, newexs, newenv} = Lx.Expand.expand(quoted, exs, env)
    {erl, newerls} = :elixir_erl_pass.translate(exp, :erl_anno.new(env.line), erls)
    {erl, newerls, newexs, newenv}
  end

end
