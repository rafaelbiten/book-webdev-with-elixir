defmodule IslandsEngine.Impl.Coordinate do
  @moduledoc false
  alias __MODULE__

  @enforce_keys [:col, :row]
  defstruct [:col, :row]

  @board_range 1..10

  def new([col: col, row: row] = coordinate) when col in @board_range and row in @board_range,
    do: {:ok, struct(Coordinate, coordinate)}

  def new(_invalid_coordinate), do: {:error, :invalid_coordinate}
end
