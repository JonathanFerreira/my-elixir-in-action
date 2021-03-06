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

defmodule TodoList.CsvImporter do
  def import(path) do
    path
    |> stripped_lines!
    |> parse_lines!
    |> TodoList.new()
  end

  defp stripped_lines!(path) do
    path
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp parse_lines!(lines) do
    lines
    |> Stream.map(&split_data!/1)
    |> Stream.map(&create_entry/1)
  end

  defp split_data!(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  defp convert_date([date_str, title]) do
    {convert_string_to_date(date_str), title}
  end

  defp convert_string_to_date(string) do
    [year, month, day] =
      string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp create_entry({date, title}) do
    %{
      date: date,
      title: title
    }
  end
end
