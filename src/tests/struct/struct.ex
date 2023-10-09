defmodule StructTest do
  ## Elixir default: creates a Person struct
  defstruct [
    name :: string,
    age :: integer
  ]
  ## LX Feat: Define named struct on same module
  defstruct Vehicle [
    model :: string,
    year :: integer
  ]
  def main() do
    b = %StructTest{name: "Person 1", age: 15}
    v = %StructTest.Vehicle{model: "FIAT", year: 2014}
    15 =b.age
    "Person 1" = b.name
    "FIAT" = v.model

    # ## Same above, __MODULE__ references itself
    # # p0 = %__MODULE__{name: "Rich Man", age: 29}
    # # v0 = %__MODULE__.Vehicle{model: "BMW", year: 2023}



    ### The Structs have default functions to get info about it
    ### Functions to low level management
    :ok
  end
end
