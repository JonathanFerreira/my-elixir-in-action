defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, name, name: global_name(name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def delete_entry(todo_server, todo_id) do
    GenServer.cast(todo_server, {:delete_entry, todo_id})
  end

  def update_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:update_entry, entry})
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @impl GenServer
  def init(name) do
    {
      :ok,
      {name, Todo.Database.get(name) || Todo.List.new()},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete_entry, todo_id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, todo_id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  # invoked when there's no activity in the server process for 10 seconds
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end
end
