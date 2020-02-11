# todo_list = TodoList.new() |> TodoList.add_entry(%{date: ~D[2018-12-19], title: "Dentist"}) |> TodoList.add_entry(%{date: ~D[2018-12-20], title: "Shopping"}) |> TodoList.add_entry(%{date: ~D[2018-12-19], title: "Movies"})


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
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_, :halt), do: :ok
end
