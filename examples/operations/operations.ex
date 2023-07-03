defmodule Operations do

  def sum(a, b) do
    a + b
  end
  def sub(a, b) do
    a - b
  end
  def mul(a, b) do
    a * b
  end
  def div(a, b) do
    a / b
  end
  def main() do
    sum(1,2)
    sub(2,1)
    mul(3,2)
    div(2,2)

    3 = sum(1,2)
    1 = sub(2,1)
    6 = mul(3,2)
    4 = div(2,2)
  end
end
