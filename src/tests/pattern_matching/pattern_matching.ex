defmodule PatternMatchingTest do

  def sum(a :: int, b ::int) :: int do
    a + b
  end
  def sub( a :: int, b ::int) :: int do
    a - b
  end
  def mul(a :: int, b :: int) :: int do
    a * b
  end
  def div(a ::int, b :: int)  :: int do
    a / b
  end

  def main() do
    3 = sum(1,2)
    1 = sub(2,1)
    6 = mul(3,2)
    4 = div(8,2)

    "Hello World" = "Hello World"
    :ok
  end
end
