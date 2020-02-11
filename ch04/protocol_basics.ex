defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: nil
end

# Implementing a protocol
defimpl String.Chars, for: TodoList do
  def to_string(_) do
    "#TodoList"
  end
end
