alias IslandsEngine.Game
alias IslandsEngine.GameSupervisor
alias IslandsEngine.Impl.Board
alias IslandsEngine.Impl.Coordinate
alias IslandsEngine.Impl.Guesses
alias IslandsEngine.Impl.Island
alias IslandsEngine.Rules

# IslandsEngine.Iex.InitialChecks.run()
# game = IslandsEngine.Iex.GameChecks.run()
# loop = IslandsEngine.Iex.Processes.run()

:observer.start()

GameSupervisor.start_game("Raf")
GameSupervisor.start_game("Fau")

true = "Raf" |> GameSupervisor.find_game_by_name() |> is_pid()
true = "Fau" |> GameSupervisor.find_game_by_name() |> is_pid()

nil = GameSupervisor.find_game_by_name("nameless_one")
