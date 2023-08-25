defmodule IslandsEngine.Impl.Guesses do
  @moduledoc false
  alias __MODULE__
  alias IslandsEngine.Impl.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new, do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  def hit(%Guesses{} = guesses, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, fn hits -> MapSet.put(hits, coordinate) end)

  def miss(%Guesses{} = guesses, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, fn misses -> MapSet.put(misses, coordinate) end)
end
