defmodule Geometry do
  # Each function has the same arity.
  # So function area has multiple clauses

  def area({:rectangle, a, b}) do
    a * b
  end

  def area({:square, a}) do
    a * a
  end

  def area({:circle, r}) do
    r * r * 3.14
  end

  # This is a default clause. It's always match to avoid raising errors
  # We always put the default clause in last, because the runtime
  # tries all clauses using the source code order
  def area(unknown) do
    {:error, {:unknown_shape, unknown}}
  end
end


# Recursivity using multiclause
# Factorial
defmodule Fact do
  def fact(0), do: 1
  def fact(n), do: n * fact(n - 1)
end

# Recursivity using multiclause
# Sum all elements in a list
defmodule ListHelper do
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)
end
