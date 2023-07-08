defmodule IO do
  def puts(str :: string) do
   :_c_.printf(str)
  end
end
