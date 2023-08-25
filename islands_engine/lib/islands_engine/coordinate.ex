defmodule IslandsEngine.Coordinate do
  @moduledoc false
  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10

  def new([row: row, col: col] = coordinate) when row in @board_range and col in @board_range,
    do: {:ok, struct(Coordinate, coordinate)}

  def new(_invalid_coordinate), do: {:error, :invalid_coordinate}
end
