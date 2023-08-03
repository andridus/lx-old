### Testing inference type from operators fuctions
defmodule Main do
  def sum(a, b) do
    a + b
  end

  def main() do
    sum(1,2)
    :ok
  end
end
