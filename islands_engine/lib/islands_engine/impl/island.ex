defmodule IslandsEngine.Impl.Island do
  @moduledoc false
  alias __MODULE__
  alias IslandsEngine.Impl.Coordinate

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  def new(shape, %Coordinate{} = island_position) when is_atom(shape) do
    with [_ | _] = offsets <- island_offsets(shape),
         %MapSet{} = coordinates <- island_coordinates(offsets, island_position) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  def guess(%Island{} = island, %Coordinate{} = coordinate) do
    if MapSet.member?(island.coordinates, coordinate) do
      {:hit, update_in(island.hit_coordinates, &MapSet.put(&1, coordinate))}
    else
      {:miss, island}
    end
  end

  def overlaps?(%Island{} = island1, %Island{} = island2) do
    not MapSet.disjoint?(island1.coordinates, island2.coordinates)
  end

  def forested?(%Island{} = island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  def shapes, do: [:dot, :square, :l_shape, :s_shape, :z_shape]

  # implemnetation details

  defp island_coordinates(island_offsets, %Coordinate{} = island_position) do
    Enum.reduce_while(island_offsets, MapSet.new(), fn offset, coordinates ->
      add_coordinate(coordinates, offset, island_position)
    end)
  end

  defp add_coordinate(coordinates, {col_offset, row_offset}, %Coordinate{col: col, row: row} = _island_position) do
    case Coordinate.new(col: col_offset + col, row: row_offset + row) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      error -> {:halt, error}
    end
  end

  defp island_offsets(:dot), do: island_offsets_from_shape("X")

  defp island_offsets(:square) do
    island_offsets_from_shape("""
    XX
    XX
    """)
  end

  defp island_offsets(:l_shape) do
    island_offsets_from_shape("""
    X
    X
    XX
    """)
  end

  defp island_offsets(:s_shape) do
    island_offsets_from_shape("""
     XX
    XX
    """)
  end

  defp island_offsets(:z_shape) do
    island_offsets_from_shape("""
    XX
     XX
    """)
  end

  defp island_offsets(_), do: {:error, :invalid_island_shape}

  defp island_offsets_from_shape(raw_shape) do
    raw_shape
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(&line_to_island_offsets/1)
  end

  defp line_to_island_offsets({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {placeholder, _col} -> String.trim(placeholder) != "" end)
    |> Enum.map(fn {_placeholder, col} -> {col, row} end)
  end
end
