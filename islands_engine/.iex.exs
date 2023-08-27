alias IslandsEngine.Impl.{Coordinate, Guesses, Island}

{:ok, coord1} = Coordinate.new(col: 1, row: 1)
{:ok, coord2} = Coordinate.new(col: 2, row: 2)

island_dot = Island.new(:dot, coord1)
island_square = Island.new(:square, coord1)
island_z = Island.new(:z_shape, coord2)

Island.overlaps?(island_dot, island_square)
|> IO.inspect(label: "island_dot overlaps with island_square?")

Island.overlaps?(island_dot, island_z)
|> IO.inspect(label: "island_dot overlaps with island_z?")

Island.forested?(island_dot)
|> IO.inspect(label: "island_dot is forested?")

Island.guess(island_dot, coord1)
|> then(fn {:hit, island_dot} -> Island.forested?(island_dot) end)
|> IO.inspect(label: "island_dot is forested now?")

guesses = Guesses.new()
