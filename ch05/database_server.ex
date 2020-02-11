defmodule DatabaseServer do
  # Interface functions
  def start do
    spawn(&loop/0)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  # Implementation function
  defp loop do
    receive do
      {:run_query, caller, query_def} ->
        send(caller, {:query_result, run_query(query_def)})
    end
    loop() # tail recursion to keep loop and server running
  end

  defp run_query(query_def) do
    Process.sleep(2000)
    "#{query_def} result"
  end
end

# Create a pool of datatabse process
# pool = Enum.map(1..100, fn _ -> DatabaseServer.start() end)

# Select which server process will execute the query
# Enum.each(1..5, fn query_def ->
#   server_pid = Enum.at(pool, :rand.uniform(100) - 1)    ①  
#   DatabaseServer.run_async(server_pid, query_def)    ②  
# end)

# Get results
# Enum.map(1..5, fn _ -> DatabaseServer.get_result end)
