defmodule IO do
  def puts(str :: string) :: atom do
   :_v_.println(str)
   :ok
  end
  def puts(integer :: int) :: atom do
   :_v_.println(integer)
   :ok
  end
end
