defmodule Unless do
  def fun_unless(clause, do: expression) do
    if(!clause, do: expression)
  end

  defmacro macro_unless(clause, do: expression) do
    quote do
      if(!unquote(clause), do: unquote(expression))
    end
  end
end

defmodule Main do
  require Unless

  def run() do
    Unless.macro_unless(true, do: IO.puts("INSIDE MACRO: this should never be printed"))
    Unless.fun_unless(true, do: IO.puts("INSIDE FUN: this should never be printed"))
  end
end
