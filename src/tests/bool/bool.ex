defmodule BoolTest do

  def main() do
    false = false && false
    false = false && true
    false = true && false
    true = true && true

    false = false || false
    true = false || true
    true = true || false
    true = true || true

    false = !true
    true = !!true
    true = !false
    false = !!false
    :ok
  end
end
