# entries = [ %{date: ~D[2018-12-19], title: "Dentist"}, %{date: ~D[2018-12-20], title: "Shopping"},%{date: ~D[2018-12-19], title: "Movies"}]

defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

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
