alias IslandsEngine.Impl.{Board, Coordinate, Guesses, Island}

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

game = Board.new()
|> tap(&IO.inspect(&1, label: "New board"))
|> Board.position_island(:island_dot, island_dot)
|> tap(&IO.inspect(&1, label: "Positioned island_dot"))
# |> then(fn {:ok, board} -> Board.position_island(board, :island_z, island_z) end)
# |> tap(&IO.inspect(&1, label: "Positioned island_z"))
|> then(fn {:ok, board} -> Board.guess(board, coord1) end)
|> tap(&IO.inspect(&1, label: "Guessed coord 1"))
# |> then(fn {:ok, board} -> Board.guess(board, coord2) end)
# |> tap(&IO.inspect(&1, label: "Guessed coord 2"))
