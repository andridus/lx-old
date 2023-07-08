defmodule Person do
  ## Elixir default: creates a Person struct
  defstruct [
    name :: string,
    age :: integer
  ]
  ## NEW: create a named struct inside Module
  # defstruct Vehicle [model :: string, year :: integer]

  def main() do
    b = %Person{name: "Person 1", age: 15}
    Lx.IO.puts("\n----- start of test ----- \n")
    Lx.IO.puts(b.age)
    Lx.IO.puts(18.8)
    Lx.IO.puts(25)
    Lx.IO.puts("Minha String")
    Lx.IO.puts(b.name)
    Lx.IO.puts()
    Lx.IO.puts("\n----- end of test ----- \n")
    # Lx.IO.puts("done\n")
    # v = %Person.Vehicle{model: "BMW", year: 2023}

    ## Same above, __MODULE__ references itself
    # p0 = %__MODULE__{name: "Rich Man", age: 29}
    # v0 = %__MODULE__.Vehicle{model: "BMW", year: 2023}

    ### The Structs have default functions to get info about it
    ### Functions to low level management
  end
end
