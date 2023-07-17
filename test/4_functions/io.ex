defmodule IO do
  def puts(str :: string) :: int do
   :_c_.printf("%s\n", str)
  end
  def puts(integer :: int) :: int do
   :_c_.printf("%d\n", integer)
  end
end
