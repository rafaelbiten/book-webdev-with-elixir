defmodule IslandsEngine.Impl.Board do
  @moduledoc false
  alias IslandsEngine.Impl.Coordinate
  alias IslandsEngine.Impl.Island

  def new do
    %{}
  end

  def all_islands_positioned?(board) do
    Enum.all?(Island.shapes(), fn shape -> Map.has_key?(board, shape) end)
  end

  def position_island(board, key, %Island{} = island) do
    if overlaps_existing_island?(board, key, island) do
      {:error, :overlapping_island}
    else
      {:ok, Map.put(board, key, island)}
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end
end
