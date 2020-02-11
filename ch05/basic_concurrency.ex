# Concurrency vs. parallelism
# It’s important to realize that concurrency doesn’t necessarily imply parallelism.
# Two concurrent things have independent execution contexts,
# but this doesn’t mean they will run in parallel.
# If you run two CPU-bound concurrent tasks and you only have one CPU core,
# parallel execution can’t happen.
# You can achieve parallelism by adding more CPU cores and relying on an efficient concurrent framework.
# But you should be aware that concurrency itself doesn’t necessarily speed things up.


# Simulates a heavy process that takes to seconds
run_query =
  fn query ->
    Process.sleep(2000)
    "Result of #{query}"
  end

IO.puts "Running heavy process sequentially - 10secs"
Enum.map(1..5, &run_query.("heavy query #{&1}"))

# Async executions
async_query =
  fn query ->
    spawn(fn -> IO.puts(run_query.(query)) end)
  end

  IO.puts "Running heavy process concurrently - 2secs"
  Enum.each(1..5, &async_query.("heavy query #{&1}"))



# Sending and receive messages

# Creates a lambda that send result to the caller
async_query =
  fn query_def ->
    caller = self()
    spawn(fn ->
      send(caller, {:query_result, run_query.(query_def)})
    end)
  end

# Calling async function
Enum.each(1..5, &async_query.("query #{&1}"))

# Creates a lambda that receive messages
get_result =
  fn ->
    receive do
      {:query_result, result} -> result
    end
  end

# Printing results
Enum.map(1..5, fn _ -> get_result.() end)
