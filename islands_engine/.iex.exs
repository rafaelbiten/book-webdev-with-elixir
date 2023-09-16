alias IslandsEngine.Game
alias IslandsEngine.Impl.Board
alias IslandsEngine.Impl.Coordinate
alias IslandsEngine.Impl.Guesses
alias IslandsEngine.Impl.Island
alias IslandsEngine.Rules

# IslandsEngine.Iex.InitialChecks.run()

{:ok, game} = Game.start_link("Raf")
game_state = :sys.get_state(game)

{:error, :rule_violation} = Game.position_island(game, :p1, :wrong_shape, 11, 1)
:ok = Game.add_player(game, "Fau")

{:error, :invalid_coordinate} = Game.position_island(game, :p1, :wrong_shape, 11, 1)
{:error, :invalid_island_shape} = Game.position_island(game, :p1, :wrong_shape, 1, 1)
:ok = Game.position_island(game, :p1, :dot, 1, 1)

{:error, :overlapping_island} = Game.position_island(game, :p1, :l_shape, 1, 1)
:ok = Game.position_island(game, :p1, :l_shape, 2, 2)
