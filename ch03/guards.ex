### Elixir terms order
# number < atom < reference < fun < port < pid < tuple < map < list < bitstring (binary)

# Guard is a logical expression that places further conditions on a clause.
defmodule TestNum do
  def test(x) when is_number(x) and x < 0 do
    :negative
  end

  def test(0), do: :zero

  def test(x) when is_number(x) and x > 0 do
    :positive
  end
end


defmodule ListHelper do
  def smallest(list) when length(list) > 0 do
    Enum.min(list)
  end

  def smallest(_), do: {:error, :invalid_argument}
end
