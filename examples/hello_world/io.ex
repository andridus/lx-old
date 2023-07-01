defmodule IO do
  def puts(str) do
   :_c_.stdio.printf('%.*s\n', 1, str)
  end
end
