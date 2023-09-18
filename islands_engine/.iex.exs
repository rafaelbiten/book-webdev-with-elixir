alias IslandsEngine.Game
alias IslandsEngine.Impl.Board
alias IslandsEngine.Impl.Coordinate
alias IslandsEngine.Impl.Guesses
alias IslandsEngine.Impl.Island
alias IslandsEngine.Rules

# IslandsEngine.Iex.InitialChecks.run()

{:ok, game} = Game.start_link("Raf")
game_state = :sys.get_state(game)

{:error, :rule_violation} = Game.position_island(game, :p1, :wrong_island_shape, 11, 1)
:ok = Game.add_player(game, "Fau")

{:error, :invalid_coordinate} = Game.position_island(game, :p1, :wrong_island_shape, 11, 1)
{:error, :invalid_island_shape} = Game.position_island(game, :p1, :wrong_island_shape, 1, 1)
:ok = Game.position_island(game, :p1, :dot, 1, 1)

{:error, :overlapping_island} = Game.position_island(game, :p1, :square, 1, 1)
:ok = Game.position_island(game, :p1, :square, 2, 2)

{:ok, _board} = Game.set_islands(game, :p1)
{:error, :islands_already_set} = Game.position_island(game, :p1, :dot, 1, 1)

{:error, :not_all_islands_positioned} = Game.set_islands(game, :p2)

:ok = Game.position_island(game, :p2, :dot, 1, 1)
:ok = Game.position_island(game, :p2, :square, 2, 2)
{:error, :rule_violation} = Game.guess(game, :p1, 4, 4)

{:ok, _board} = Game.set_islands(game, :p2)

_result = Game.guess(game, :p1, 4, 4)
