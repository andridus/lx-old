defmodule Lx.IO do

  def puts(a :: int) do
   :_c_.printf("%d\n",a)
  end
  def puts(a :: float) do
   :_c_.printf("%f\n",a)
  end
  def puts(a :: string) do
   :_c_.printf("%s\n",a)
  end
  def puts() do
   :_c_.printf("now\n")
  end
end
