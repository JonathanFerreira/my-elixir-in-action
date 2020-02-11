defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  def add(server_pid, number), do: send(server_pid, {:add, number})
  def sub(server_pid, number), do: send(server_pid, {:sub, number})
  def mult(server_pid, number), do: send(server_pid, {:mult, number})
  def div(server_pid, number), do: send(server_pid, {:div, number})

  def value(server_pid) do
    send(server_pid, {:value, self()})
    receive do
      {:response, value} -> IO.puts value
    end
  end

  defp loop(current_value) do
    new_value = receive do
      message -> process_message(current_value, message)
    end
    loop new_value
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mult, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end

  defp process_message(current_value, invalid_request) do
    IO.puts "Invalid request #{inspect invalid_request}"
    current_value
  end
end
