# An Agent copy provided by GenServer

defmodule MyAgent do
  use GenServer

  def start_link(init_function) do
    GenServer.start_link(__MODULE__, init_function)
  end

  def init(init_function) do
    {:ok, init_function.()}
  end

  def get(pid, fun) do
    GenServer.call(pid, {:get, fun})
  end

  def update(pid, fun) do
    GenServer.call(pid, {:update, fun})
  end

  def handle_call({:get, fun}, _from, state) do
    response = fun.(state)
    {:reply, response, state}
  end

  def handle_call({:update, fun}, _from, state) do
    new_state = fun.(state)
    {:reply, :ok, new_state}
  end
end
