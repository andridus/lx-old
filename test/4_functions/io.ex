defmodule IO do
  def puts(str :: string) :: atom do
   :_c_.printf("%s\n", str)
   :ok
  end
  def puts(integer :: int) :: atom do
   :_c_.printf("%d\n", integer)
   :ok
  end
end
