defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
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

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, todo_id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, todo_id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list}
    }
  end
end
