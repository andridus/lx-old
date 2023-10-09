defmodule EnumTest do
  ## Elixir default: creates a Person struct
  defenum Kind [ :dog, :cat, :rabbit ]
  def print(a :: string) do
    :FFI.v.println(a)
    # nil
  end
  def print(a :: EnumTest.Kind@) do
    :FFI.v.println(a)
    # nil
  end
  def main() do
    dog = EnumTest.Kind@dog
    cat = EnumTest.Kind@cat
    rabbit = EnumTest.Kind@rabbit
    print(cat)
    print(dog)
    print("olá mundo \n")
    print(rabbit)
    :ok
  end
end
