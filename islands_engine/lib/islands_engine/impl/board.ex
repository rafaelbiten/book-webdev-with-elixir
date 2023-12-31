defmodule IslandsEngine.Impl.Board do
  @moduledoc false
  alias IslandsEngine.Impl.Coordinate
  alias IslandsEngine.Impl.Island

  def new do
    %{}
  end

  def position_island(board, key, %Island{} = island) do
    if overlaps_existing_island?(board, key, island) do
      {:error, :overlapping_island}
    else
      {:ok, Map.put(board, key, island)}
    end
  end

  def check_all_islands_positioned(board) do
    if Enum.all?(Island.shapes(), fn shape -> Map.has_key?(board, shape) end) do
      {:ok, board}
    else
      {:error, :not_all_islands_positioned}
    end
  end

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_for_hits(coordinate)
    |> send_result(board)
  end

  # implemnetation details

  defp send_result(:miss, board) do
    won? = false
    forested_island = nil
    {:ok, :miss, board, forested_island, won?}
  end

  defp send_result({key, island_hit}, board) do
    updated_board = Map.put(board, key, island_hit)

    if Island.forested?(island_hit) do
      won? = Enum.all?(updated_board, fn {_key, island} -> Island.forested?(island) end)
      forested_island = key
      {:ok, :hit, updated_board, forested_island, won?}
    else
      won? = false
      forested_island = nil
      {:ok, :hit, updated_board, forested_island, won?}
    end
  end

  defp check_for_hits(board, %Coordinate{} = coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island_hit} -> {key, island_hit}
        {:miss, _} -> nil
      end
    end)
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end
end
