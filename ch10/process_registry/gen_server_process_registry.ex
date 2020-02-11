defmodule SimpleRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def whereis(key) do
    GenServer.call(__MODULE__, {:whereis, key})
  end

  def register(key) do
    GenServer.call(__MODULE__, {:register, key, self()})
  end

  @impl GenServer
  def handle_call({:whereis, key}, _from, state) do
    response = case Map.get(state, key) do
      value -> value
    end
    {:reply, response, state}
  end

  @impl GenServer
  def handle_call({:register, key, pid}, _from, state) do
    case Map.fetch(state, key)  do
      {:ok, _} ->
        {:reply, :error, state}
      :error ->
        Process.link(pid)
        {:reply, :ok, Map.put(state, key, pid)}
    end
  end

  @impl GenServer
  def handle_info({:EXIT, from_pid, _reason}, state) do
    {:noreply, unregister_process(state, from_pid)}
  end

  defp unregister_process(registers, pid) do
    registers
    |> Enum.reject(fn {_, value} -> value == pid end)
    |> Enum.into(%{})
  end
end
