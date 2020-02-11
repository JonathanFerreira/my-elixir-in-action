# Exercicies to practice "tail recursion"
defmodule ListHelper do
  @doc "Returns length of a list"
  def list_len(list), do: calc_list_length(list, 0)

  defp calc_list_length([], len), do: len

  defp calc_list_length([_| tail], len) do
    calc_list_length(tail, len + 1)
  end

  @doc "Returns a list start with from and ending in to"
  def range(from, to) do
    calc_range(from, to, [])
  end

  defp calc_range(from, to, list) when from > to, do: list

  defp calc_range(from, to, list) do
    calc_range(from, to - 1, [to | list])
  end

  @doc "Returns a list only with positive numbers"
  def positive(list), do: build_positive_list(list, [])

  defp build_positive_list([], result), do: Enum.reverse(result)

  defp build_positive_list([head | tail], result) when head > 0 do
    build_positive_list(tail, [head | result])
  end

  defp build_positive_list([_ | tail], result) do
    build_positive_list(tail, result)
  end
end
