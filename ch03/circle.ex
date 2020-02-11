defmodule Circle do
  @moduledoc """
    Implements basic circle functions
  """

  @pi 3.14159

  @doc " Computes de area of a circle"
  def are(r), do: r * r * @pi

  @doc "Computes de circumference of a circle"
  def circumference(r), do: 2 * r * @pi
end
