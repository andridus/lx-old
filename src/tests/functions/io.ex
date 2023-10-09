defmodule IO do
  def puts(str :: string) :: atom do
    :FFI.v.println(str)
   :ok
  end
  def puts(integer :: int) :: atom do
   :FFI.v.println(integer)
   :ok
  end
end
