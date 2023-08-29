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

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_for_hits(coordinate)
    |> send_result(board)
  end

  # implemnetation details

  defp send_result(:miss, board), do: {:miss, board}

  defp send_result({key, island_hit}, board) do
    updated_board = Map.put(board, key, island_hit)

    if Island.forested?(island_hit) do
      {:hit, updated_board, forested: key,
       won: Enum.all?(updated_board, fn {_key, island} -> Island.forested?(island) end)}
    else
      {:hit, updated_board, forested: nil, won: false}
    end
  end

  def position_island(board, key, %Island{} = island) do
    if overlaps_existing_island?(board, key, island) do
      {:error, :overlapping_island}
    else
      {:ok, Map.put(board, key, island)}
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
