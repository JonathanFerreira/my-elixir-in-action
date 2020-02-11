# Exercicies to practice "non-tail recursion"
defmodule ListHelper do
  @doc "Returns length of a list"
  def list_len([]), do: 0

  def list_len([_| tail]) do
    1 + list_len(tail)
  end

  @doc "Returns a list start with from and ending in to"
  def range(from, to) when from > to do
    []
  end

  def range(from, to) do
    [from | range(from + 1, to)]
  end

  @doc "Returns a list only with positive numbers"
  def positive([]), do: []

  def positive([head | tail]) when head < 0 do
    positive(tail)
  end

  def positive([head | tail]) do
    [head | positive(tail)]
  end
end
