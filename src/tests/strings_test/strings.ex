defmodule StringsTest do
  def main() do
    ## String literal
    "Hello Lx"
    "Hello
    Lx"
    "👩‍💻 こんにちは Lx 💫"

    ## MultilineString literal
    """
      Multiline String
      Other Line
      And other line
    """

    ### Concatenation
    "name:" <> "Fulano"
    name = "Fulano"
    "Hello, Fulano!" = "Hello, " <> name <> "!"
    "Fulano, Hello" = name <> ", Hello"

    ### Interpolation
    "Hello, Fulano!" = "Hello, #{name}!"

    ### Scape Sequences
   "Here is a double quote -> \" <-"
    "C:\\Users\\Lx"
  end
end
