defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def start, do: ServerProcess.start(__MODULE__)
  def init(), do: %TodoList{}

  def add_entry(pid, entry) do
    ServerProcess.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def update_entry(pid, entry \\ %{}) do
    ServerProcess.cast(pid, {:update_entry, entry})
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

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end


  #### handle casts

  def handle_cast({:add_entry, entry}, state) do
    entry = Map.put(entry, :id, state.auto_id)

    new_entries = Map.put(
      state.entries,
      state.auto_id,
      entry
    )

    %TodoList{state |
      entries: new_entries,
      auto_id: state.auto_id + 1
    }
  end

  def handle_cast({:update_entry, entry}, state) do
    update_entry(state, entry.id, fn _ -> entry end)
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    %TodoList{state | entries: Map.delete(state.entries, entry_id)}
  end

  #### handle calls

  def handle_call({:entries, date}, state) do
    result =
      state.entries
      |> Stream.filter(fn {_, entry} -> entry.date == date end)
      |> Enum.map(fn {_, entry} -> entry end)

    {result, state}
  end
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )
        loop(callback_module, new_state)

    end
  end
end
