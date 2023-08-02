defmodule Bool do

  def main() do
    false = false && false
    false = false && true
    false = true && false
    true = true && true

    false = false || false
    false = false || true
    true = true || false
    true = true || true

    false = !true
    true = !!true
    true = !false
    false = !!false
  end
end
