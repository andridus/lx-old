defmodule Lx do
  @doc """
    Main module of Lx compiler
  """
  alias Lx.Compiler.Builtin

  @doc """
    Main Execution
  """
  def main() do
    if 1 do
      Builtin.print("Olá Mundo")
    else
      Builtin.print("Oh No!")
    end
  end
end
