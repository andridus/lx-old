defmodule Lx.ReplServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call(:result, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:compile, code, args}, state) do
    {result, _} = Code.eval_string(code, args)
    {:noreply, [result | state]}
  end

  #### API
  def compile(code, args \\ []), do: GenServer.cast(__MODULE__, {:compile, code, args})
  def result(), do: GenServer.call(__MODULE__, :result)
end
