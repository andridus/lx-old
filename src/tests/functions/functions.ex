defmodule Functions do
  def sum(a :: integer, b :: integer) :: integer do
    a + b
  end
  def main() do
    a = sum(5,2)
    IO.puts("Hello Lx World\n")
    IO.puts(a)
    :ok
  end
end
