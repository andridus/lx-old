defmodule Functions do
  def sum(a :: int, b :: int) :: int do
    a + b
  end
  def main() do
    a = sum(5,2)
    IO.puts("Hello Lx World\n")
    IO.puts(a)
    :ok
  end
end
