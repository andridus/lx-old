defmodule Lx do
  @doc """
    Main module of Lx compiler
  """
  alias Lx.Compiler.Builtin

  @doc """
    Main Execution
  """
  def main() do
    Builtin.print("Olá Mundo")
  end
end
