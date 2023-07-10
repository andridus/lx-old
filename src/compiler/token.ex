# Copyright (c) 2023 Helder de Sousa. All rights reserved.
# Use of this source code is governed by an MIT license
# that can be found in the LICENSE file.

defmodule Compiler.Token do
  alias Compiler.Token
  @moduledoc """
    Collection of token definitions to Lx compiler
  """
  defstruct [
    kind        :: Token.Kind
    literal     :: string
    value       :: Token.LiteralValue
    line_num    :: integer
    pos         :: integer
    pos_inline  :: integer
  ]

  defstruct LiteralValue [
    sval :: string
    ival :: integer
    fval :: float
  ]

  defenum Kind [
    # Types
    :ignore, :eof, :newline, :ident, :atom, :sigil, :list, :tuple, :integer, :float, :str, :str_inter, :charlist, :map, :struct,
    # Operators
    :typedef, :bang, :not, :plus, :minus, :mul, :div, :mod, :xor, :pipe, :inc, :dec, :and, :bit_not, :logical_or, :question, :comma, :semicolon, :colon, :colon_space, :arrow, :right_arrow, :left_arrow, :amp, :capture, :hash, :dollar, :arrob, :assign,
    # {} () []
    :lcbr, :rcbr, :lpar, :rpar, :lsbr, :rsbr,
    # == != <= < >= >
    :eq, :seq, :eqt, :ne, :sne, :gt, :lt, :ge, :le,
    #
    :module, :coment_line, :doc, :moduledoc, :multistring, :dot, :range, :ellipsis, :plus_concat, :minus_concat, :string_concat,
    ## Keyword
    :key_keyword, :key_and, :key_or, :key_true, :key_false, :key_else, :key_nil, :key_when,
    :key_not, :key_in, :key_fn, :key_do, :key_end, :key_catch, :key_rescue, :key_after, :key_def, :key_defp, :key_defmacro, :key_defmacrop, :key_defmodule, :key_import, :key_defstruct, :key_defenum, :key_deftype, :key_alias, :key_require,
  ]
end

  pub @token_str build_token_string()


  #### ------------- functions -----------------

  @doc """
    Generate all strings for Kinds
  """
  def build_token_string :: []keyword do
    for {key, value} <- Token.Kind.items(), do: {key, to_string(value) }
  end

  @doc """
    Converts to string
     - Kind
     - Token
  """
  def to_string(kind :: Token.Kind) :: string do
    case kind do
      # Flow
      :ignore -> "IGNORE"
      :eof -> "EOF"
      :newline -> "NEWLINE"
      # Type
      :ident, :atom, :sigil, :list,
      :tuple, :integer, :float, :string,
      :charlist, :map, :struct  -> kind
      :string_inter -> "string_interpolation"
      # Operators
      :typedef -> "::"
      :bang -> "!"
      :not -> "!"
      :plus -> "+"
      :minus -> "-"
      :mul -> "*"
      :div -> "/"
      :mod -> "%"
      :xor -> "^"
      :pipe -> "|"
      :inc -> "++"
      :dec -> "--"
      :and -> "&&"
      :bit_not -> "-"
      :logical_or -> "||"
      :question -> "?"
      :comma -> ","
      :semicolon -> ";"
      :colon -> ":"
      :colon_space -> ":s"
      :arrow -> "=>"
      :right_arrow -> "->"
      :left_arrow -> "<-"
      :amp -> "&"
      :capture -> "&"
      :hash -> "#"
      :dollar -> "$"
      :arrob -> "@"
      :assign -> "="
      # {} () []
      :lcbr -> "{"
      :rcbr -> "}"
      :lpar -> "("
      :rpar -> ")"
      :lsbr -> "["
      :rsbr -> "]"
      # == != <= < >= >
      :eq -> "=="
      :seq -> "==="
      :eqt -> "~="
      :ne -> "!="
      :sne -> "!=="
      :gt -> ">"
      :lt -> "<"
      :ge -> ">="
      :le, -> "<="
      #
      :module -> "module"
      :coment_line -> "comment"
      :doc -> "doc"
      :moduledoc -> "moduledoc"
      :multistring -> "multistring"
      :dot -> "."
      :range -> ".."
      :ellipsis -> "..."
      :plus_concat -> "++"
      :minus_concat -> "--"
      :string_concat -> "<>"
      ## Keyword
      :key_keyword -> "keyword"
      :key_and -> "and"
      :key_or -> "or"
      :key_true -> "true"
      :key_false -> "false"
      :key_else -> "else"
      :key_nil -> "nil"
      :key_when -> "when"
      :key_not -> "not"
      :key_in -> "in"
      :key_fn -> "fn"
      :key_do -> "do"
      :key_end -> "each"
      :key_catch -> "catch"
      :key_rescue -> "rescue"
      :key_after -> "after"
      :key_def -> "def"
      :key_defp -> "defp"
      :key_defmacro -> "defmacro"
      :key_defmacrop -> "defmacrop"
      :key_defmodule -> "defmodule"
      :key_import -> "import"
      :key_defstruct -> "defstruct"
      :key_defenum -> "defenum"
      :key_deftype -> "deftype"
      :key_defstructp -> "defstructp"
      :key_defenump -> "defenump"
      :key_deftypep -> "deftypep"
      :key_alias -> "alias"
      :key_require, -> "require"
    end
  end
  def to_string(token :: Token) :: string do
    "[#{token.kind.to_string()}] '#{token.literal}'"
  end

end
