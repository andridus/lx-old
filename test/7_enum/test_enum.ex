defmodule Animals do
  ## Elixir default: creates a Person struct
  defenum Kind [ :dog, :cat, :rabbit ]
  def print(a :: string) do
    :_v_.println(a)
  end
  def print(a :: Animals.Kind@) do
    :_v_.println(a)
  end
  def main() do
    dog = Animals.Kind@dog
    cat = Animals.Kind@cat
    rabbit = Animals.Kind@rabbit
    print(dog)
    print("olá mundo \n")
    print(rabbit)
    :ok
  end
end
