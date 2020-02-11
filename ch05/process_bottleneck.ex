# Simulates a bottleneck on echo server.
# The server can handle only one message per second
# All processes depend on the echo server, they’re constrained by its throughput.

### HOW TO USE

# server = Server.start()
# Enum.each(
#  1..5,
#  fn i ->
#    spawn(fn ->    ①  
#      IO.puts("Sending msg ##{i}")
#      response = Server.send_msg(server, i)    ②  
#      IO.puts("Response: #{response}")
#    end)
#  end
#)

defmodule Server do
  def start do
    spawn(fn -> loop() end)
  end

  def send_message(server, message) do
    send(server, {self(), message})
    receive do
      {:response, response} -> response
    end
  end

  defp loop do
    receive do
      {caller, msg} ->
        Process.sleep(1000)
        send(caller, {:response, msg})
    end

    loop()
  end
end
