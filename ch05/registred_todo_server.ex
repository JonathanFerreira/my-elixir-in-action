defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def add_entry(todo_list, entry) do
    # add id key to new entry
    entry = Map.put(entry, :id, todo_list.auto_id)

    # creates new entries adding auto_id as key and entry as value
    new_entries = Map.put(
      todo_list.entries,
      todo_list.auto_id,
      entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      auto_id: todo_list.auto_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list
      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        # save updated entry by lambda function
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        # update entries with id and new_entry
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        # merge todo_list with new entries
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

# This server uses registred process to simplify client interface
# If you know there will always be only one instance of some type of server,
# you can give the process a local name and use that name to send messages to the process

## Rules

# * The name can only be an atom.
# * A single process can have only one name.
# * Two processes can’t have the same name.

defmodule TodoServer do
  def start do
    server_pid = spawn(fn -> loop(TodoList.new()) end)
    Process.register(server_pid, :todo_server)
  end

  def add_entry(todo) do
    send(:todo_server, {:add_entry, todo})
  end

  def update_entry(todo) do
    send(:todo_server, {:update_entry, todo})
  end

  def delete_entry(todo_id) do
    send(:todo_server, {:delete_entry, todo_id})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message -> process_message(todo_list, message)
    end

    loop new_todo_list
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end


########## HOW TO USE

##### Start server process to receive messages
# todo_server = TodoServer.start()

#### Add todos
# TodoServer.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
# TodoServer.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
# TodoServer.add_entry(%{date: ~D[2018-12-19], title: "Movies"})

#### Update todo
# In this specific case we change the day of our first item
# TodoServer.update_entry(%{id: 1, date: ~D[2018-12-21], title: "Dentist"})

#### Delete todo
# Delete item with id = 3
# TodoServer.delete_entry(3)

#### List todos
# TodoServer.entries(~D[2018-12-19])
