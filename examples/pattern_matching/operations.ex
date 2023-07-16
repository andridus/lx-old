defmodule Operations do

  def sum(a :: int, b ::int) :: int do
    a + b
  end
  def sub( a :: int, b ::int) do
    a - b
  end
  def mul(a :: int, b :: int) do
    a * b
  end
  def div(a ::int, b :: int) do
    a / b
  end
  def main() do
    a = sum(1,2)
    b = sub(2,1)
    c = mul(3,2)
    d = div(2,2)

    :_c_.printf("%d %d %d %d\n", a, b, c, d )
    :_c_.printf("\n")
    :_c_.printf("*****************\n\n")

    # VALIDATE PATTERN MATCHING
    # 3 = sum(1,2)
    # 1 = sub(2,1)
    # 6 = mul(3,2)
    # 4 = div(2,2)
  end
end
