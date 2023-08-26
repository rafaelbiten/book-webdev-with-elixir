alias IslandsEngine.Impl.{Coordinate, Guesses, Island}

{:ok, coord1} = Coordinate.new(col: 1, row: 1)
{:ok, coord2} = Coordinate.new(col: 2, row: 2)

island_square = Island.new(coord1, :square)
island_z = Island.new(coord2, :z_shape)

guesses = Guesses.new()
