defmodule HelloWorld do
  def sum(a :: int, b :: int) :: int do
    a + b
  end
  def main() do
    IO.puts("Hello Lx World\n")
    a = sum(5,2)
    IO.puts(a)
  end
end
