defmodule IO do
  def puts(str) do
   :c_extern.stdio.printf(str)
  end
end
