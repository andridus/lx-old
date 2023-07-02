defmodule IO do
  def puts(str :: string) do
   :_c_.stdio.printf(str)
  end
end
