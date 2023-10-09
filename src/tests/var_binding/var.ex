defmodule VarBindingTest do

  # @__COMPILER__ [:disable_type_match]
  def main() do
    x = 1
    y = x
    # TODO: rebinding variable
    # x = 2
    # y = y + 2

    # 2 = x
    # 3 = y
    1 = x
    1 = y

    ### force a type (unecessary)
    z :: float = 1.5

    ## TODO: Rebinding values with other type
    # x :: float = 1.5
    # x = 2.6
    # y = x

    # 2.6 = x
    # 2.6 = y
    z
  end
end
