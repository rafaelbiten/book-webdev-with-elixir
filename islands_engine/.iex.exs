alias IslandsEngine.Game
alias IslandsEngine.Impl.Board
alias IslandsEngine.Impl.Coordinate
alias IslandsEngine.Impl.Guesses
alias IslandsEngine.Impl.Island
alias IslandsEngine.Rules

# IslandsEngine.Iex.InitialChecks.run()

{:ok, game} = Game.start_link("Raf")
game_state = :sys.get_state(game)

Game.add_player(game, "Fau")

# Process.info(game)
# IO.inspect(game_state.player1.name, label: "Player1")
