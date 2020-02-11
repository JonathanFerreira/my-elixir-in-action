defmodule KeyValueStore do
  # interface function
  def start do
    ServerProcess.start(__MODULE__)
  end

  # interface function
  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  # interface function
  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  # Method used in generic server to set initial state
  def init do
    %{}
  end

  # handle synchronous requests
  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end

  # handle synchronous requests
  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end

  # handle asynchronous requests
  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end
end

# Generic server handmake
defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  # call is used for synchronous requests
  # function to issue requests to the server process
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  # cast is used for asynchronous requests FIRE-AND-FORGET
  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      # synchronous
      {:call, request, caller} ->
        {response, new_state} =
          # Invokes the callback to handle the message
          callback_module.handle_call(
            request,
            current_state
          )
          # Sends response back to caller
          send(caller, {:response, response})
          # Loops with the new state
          loop(callback_module, new_state)

      # asynchronous
      {:cast, request} ->
        new_state = callback_module.handle_cast(
          request,
          current_state
        )
        loop(callback_module, new_state)
    end
  end
end
