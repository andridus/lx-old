-module(lx_erl_compile_server).
-beahviour(gen_server).

-export([start_link/1, eval_ast_from_string/1, client/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {socket}).

start_link(Socket) ->
  gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
  gen_server:cast(self(), accept),
  {ok, #state{socket=Socket}}.

handle_cast(accept, State = #state{socket=ListenSocket}) ->
  {ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
  lx_erl_compile_server_sup:start_socket(),
  {noreply, State#state{socket=AcceptSocket}};
handle_cast(_, State) ->
  {noreply, State}.

handle_info({tcp, Socket, "quit"++_}, State) ->
  gen_tcp:close(Socket),
  {stop, normal, State};
handle_info({tcp, Socket, Msg}, State) ->
  send(Socket, Msg, []),
  {noreply, State};
handle_info({tcp_closed, _Socket}, State) -> {stop, normal, State};
handle_info({tcp_error, _Socket}, State) -> {stop, normal, State};
handle_info(E, State) ->
  io:fwrite("unexpected: ~p~n", [E]),
  {noreply, State}.

handle_call(_E, _From, State) -> {noreply, State}.
terminate(_Reason, _Tab) -> ok.
code_change(_OldVersion, Tab, _Extra) -> {ok, Tab}.

send(Socket, Str, Args) ->
  try
    Value0 = eval_ast_from_string(Str),
    Value1 = io_lib:format("~p~n", [Value0], Args),
    Bin = erlang:list_to_bitstring(Value1),
    ok = gen_tcp:send(Socket, Bin),
    ok = inet:setopts(Socket, [{active, once}]),
    ok
  catch
    _Class:Error ->
      Error0 = io_lib:format("~p", [Error], Args),
      Bin1 = erlang:list_to_bitstring(Error0),
      ok = gen_tcp:send(Socket, Bin1),
      ok = inet:setopts(Socket, [{active, once}]),
      ok
  end.

eval_ast_from_string(String) ->
  try
    AST = string_to_ast(String),
    eval_ast(AST)
  catch
    _:_Error ->
      error
  end.

eval_ast(AST) ->
  Env = [],
  {value, Val, _} = erl_eval:expr(AST, Env),
  Val.
string_to_ast(String) ->
  {ok,Tokens,_EndLine} = erl_scan:string(String++"."),
  {ok,AbsForm} = erl_parse:parse_exprs(Tokens),
  {value,Value,_Bs} = erl_eval:exprs(AbsForm, erl_eval:new_bindings()),
  Value.

client(Port, Message) ->
  {ok, Sock} = gen_tcp:connect("localhost", Port, [binary, {packet, 0}, {active, once}]),
  ok = gen_tcp:send(Sock, Message),
  A = gen_tcp:recv(Sock,0),
  io:fwrite("~p ~n", [A]),
  ok = gen_tcp:close(Sock).
