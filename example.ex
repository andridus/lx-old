defmodule Test do
  def sum(a, b) do
    a + b
  end
end
value = Test.sum(5,1)
assert 6 = value
