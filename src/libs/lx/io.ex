defmodule Lx.IO do

  def puts(a :: int) :: atom do
   :FFI.v.println(a)
   :ok
  end
  def puts(a :: float) :: atom do
   :FFI.v.println(a)
   :ok
  end
  def puts(a :: string) :: atom do
   :FFI.v.println(a)
   :ok
  end
end
