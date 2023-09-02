alias IslandsEngine.Rules
alias IslandsEngine.Impl.{Board, Coordinate, Guesses, Island}

IO.puts(~s"
# Core components and quick checks
")

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

IO.puts(~s"
# Playing the game with the core modules
")

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

IO.puts(~s"
# Game rules
")

Rules.new()
|> tap(&IO.inspect(&1, label: "Rules initial state"))
|> then(fn rules -> Rules.check(rules, :set_player) end)
|> tap(&IO.inspect(&1, label: "Rules after setting players"))
|> then(fn {:ok, rules} -> Rules.check(rules, {:position_islands, :p1}) end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:position_islands, :p2}) end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:position_islands, :p1}) end)
|> tap(&IO.inspect(&1, label: "Rules let players position islands freely before locking them"))
|> then(fn {:ok, rules} -> Rules.check(rules, {:set_islands, :p1}) end)
|> tap(&IO.inspect(&1, label: "Rules locks player 1 islands"))
|> tap(fn {:ok, rules} ->
    IO.puts("🔥 Rules :error and won't let player 1 position its islands anymore")
    :error = Rules.check(rules, {:position_islands, :p1})
  end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:position_islands, :p2}) end)
|> tap(&IO.inspect(&1, label: "Rules still lets player 2 position its islands"))
|> then(fn {:ok, rules} -> Rules.check(rules, {:set_islands, :p2}) end)
|> tap(&IO.inspect(&1, label: "Rules locks player 2 islands and starts the game"))
|> then(fn {:ok, rules} -> Rules.check(rules, {:guess_coordinate, :p1}) end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:guess_coordinate, :p2}) end)
|> tap(fn {:ok, rules} ->
  IO.puts("🔥 Rules :error and won't let p2 play twice in a row")
  :error = Rules.check(rules, {:guess_coordinate, :p2})
end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:guess_coordinate, :p1}) end)
|> then(fn {:ok, rules} -> Rules.check(rules, {:guess_coordinate, :p2}) end)
|> tap(&IO.inspect(&1, label: "Rules let players guess coordinates, starting with p1"))
