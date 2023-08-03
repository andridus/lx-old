defmodule PatternMatching do

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
    a = sum(1,2)
    b = sub(2,1)
    c = mul(3,2)
    d = div(2,2)

    :_v_.println(a)
    :_v_.println(b)
    :_v_.println(c)
    :_v_.println(d)
    :_v_.println("#{a} #{b} #{c} #{d}")
    :_v_.println("\n")
    :_v_.println("*****************\n\n")

    # VALIDATE PATTERN MATCHING WITH TERMS
    3 = sum(1,2)
    1 = sub(2,1)
    6 = mul(3,2)
    4 = div(8,2)

    "Hello World" = "Hello Home"
    :ok
  end
end
