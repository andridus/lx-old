defmodule Person do
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
    b = %Person{name: "Person 1", age: 15}
    Lx.IO.puts("\n----- start of test ----- \n")
    v = %Person.Vehicle{model: "FIAT", year: 2014}
    Lx.IO.puts(b.age)
    Lx.IO.puts(b.name)
    Lx.IO.puts(v.model)

    ## Same above, __MODULE__ references itself
    # p0 = %__MODULE__{name: "Rich Man", age: 29}
    # v0 = %__MODULE__.Vehicle{model: "BMW", year: 2023}

    Lx.IO.puts("\n----- end of test ----- \n")


    ### The Structs have default functions to get info about it
    ### Functions to low level management
    :ok
  end
end
