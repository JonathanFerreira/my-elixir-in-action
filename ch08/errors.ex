# A runtime error has a type, which can be :error, :exit, or :throw.

try_helper = fn fun ->
  try do
    fun.()
    IO.puts("No error.")
  catch type, value ->
    IO.puts("Error\n  #{inspect(type)}\n  #{inspect(value)}")
  end
end

try_helper.(fn -> raise("Something went wrong") end)
try_helper.(fn -> throw("Something went wrong") end)
try_helper.(fn -> exit("Something went wrong") end)

# After clause always be executed try block
try do
  throw("Something went wrong")
catch
  _,_ -> IO.puts("Error caught")
after
  IO.puts("Cleanup code")
end

# You can use pattern matching on catch clause
try do
  throw({:result, "Done!"})
catch
  {:result, msg} -> IO.puts msg
  _, _ -> IO.puts "Nothing here"
end

## Linking processes
# By default, when a process receives an exit signal from another process,
# and that signal is anything other than :normal, the linked process terminates as well.
# In other words, when a process terminates abnormally, the linked process is also taken down.

spawn(fn ->
  spawn_link(fn ->
    Process.sleep(1000)
    IO.puts("Process 2 finished")
  end)

  raise("Something went wrong")
end)


## Monitors
# Monitor is something like a unidirectional link.

target_pid = spawn(fn ->
  Process.sleep(1000)
end)

Process.monitor(target_pid)

receive do
  msg -> IO.inspect(msg)
end
