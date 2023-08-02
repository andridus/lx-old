defmodule Var do

  def main() do
    x = 1
    y = x
    x = 2
    y = y + 2

    2 = x
    3 = y

    ### Type anotations
    x :: float = 1.5
    x = 2.6
    y = x

    2.6 = x
    2.6 = y
  end
end
