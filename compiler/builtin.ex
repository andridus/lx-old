defmodule Lx.Compiler.Builtin do
  @moduledoc """
   Essential functions to compiler program
  """
  alias Lx.Compiler.FILE

  @doc """
    Check if is_nil any term
  """
  def is_nil(nil) :: bool do
    true
  end
  def is_nil(_ :: any) :: bool do
    false
  end

  @doc """
    Prints string on console
  """
  def print(str :: string) :: nil do
    :_c_.printf("%s\n", str)
  end

  @doc """
    Reads file from path
  """

  def read_file(path :: string) :: {:ok}FILE do

    :COMPILER__ensure_left_type__
    fptr :: nil = :_c_.fopen(path, "r")

    if is_nil(fptr) do
      {:error, "not opened"}
    else
      {:ok, %FILE{ptr: fptr, path: path}}
    end
  end

  @doc """
    Closes file opened
  """
  def close_file(file :: FILE) :: {:ok}bool do
    result = :_c_.fclose(file.ptr) :: int
    if result == nil do
      {:error, "cant close file"}
    else
      {:ok, true}
    end
  end
end
