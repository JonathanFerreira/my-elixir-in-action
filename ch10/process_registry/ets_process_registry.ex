defmodule SimpleRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    Process.flag(:trap_exit, true)
    {:ok, nil}
  end

  def register(key) do
    IO.inspect(__MODULE__)
    Process.link(Process.whereis(__MODULE__))
    if :ets.insert(__MODULE__, {key, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  @impl GenServer
  def handle_info({:EXIT, from_pid, _reason}, state) do
    IO.inspect("Saida rastreada")
    IO.inspect(from_pid)
    :ets.match_delete(__MODULE__, {:_, from_pid})
    {:noreply, state}
  end
end
