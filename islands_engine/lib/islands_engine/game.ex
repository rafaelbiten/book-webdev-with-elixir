defmodule IslandsEngine.Game do
  @moduledoc false
  use GenServer, restart: :transient

  alias IslandsEngine.GameCache
  alias IslandsEngine.Impl.Board
  alias IslandsEngine.Impl.Coordinate
  alias IslandsEngine.Impl.Guesses
  alias IslandsEngine.Impl.Island
  alias IslandsEngine.Rules

  @players [:p1, :p2]
  @timeout :timer.minutes(30)

  # client

  def start_game(player_one_name) do
    DynamicSupervisor.start_child(
      IslandsEngine.DynamicSupervisor,
      {__MODULE__, player_one_name}
    )
  end

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  # 2 aliases to get the game state
  defdelegate get_state(game), to: :sys
  defdelegate state(game), to: :sys, as: :get_state

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def position_island(game, player, shape, col, row) when player in @players do
    GenServer.call(game, {:position_island, player, shape, col, row})
  end

  def set_islands(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  def guess(game, player, col, row) when player in @players do
    GenServer.call(game, {:guess, player, col, row})
  end

  # server

  def init(name) do
    case GameCache.restore_game(name) do
      nil ->
        player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
        player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
        new_game_state = %{p1: player1, p2: player2, rules: %Rules{}}
        GameCache.store_game(new_game_state.p1.name, new_game_state)
        {:ok, new_game_state, @timeout}

      game_state ->
        {:ok, game_state, @timeout}
    end
  end

  def handle_call({:add_player, name}, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, :add_player) do
      game_state
      |> put_in([:p2, :name], name)
      |> put_in([:rules], rules)
      |> reply(:ok)
    else
      error -> reply(game_state, error)
    end
  end

  def handle_call({:position_island, player, shape, col, row}, _from, game_state) do
    with player_board <- get_in(game_state, [player, :board]),
         {:ok, rules} <- Rules.check(game_state.rules, {:position_island, player}),
         {:ok, island_coordinate} <- Coordinate.new(col: col, row: row),
         {:ok, island} <- Island.new(shape, island_coordinate),
         {:ok, board} <- Board.position_island(player_board, shape, island) do
      game_state
      |> put_in([player, :board], board)
      |> put_in([:rules], rules)
      |> reply(:ok)
    else
      error -> reply(game_state, error)
    end
  end

  def handle_call({:set_islands, player}, _from, game_state) do
    with player_board <- get_in(game_state, [player, :board]),
         {:ok, rules} <- Rules.check(game_state.rules, {:set_islands, player}),
         {:ok, board} <- Board.check_all_islands_positioned(player_board) do
      game_state
      |> put_in([:rules], rules)
      |> reply({:ok, board})
    else
      error -> reply(game_state, error)
    end
  end

  def handle_call({:guess, player, col, row}, _from, game_state) do
    with opponent <- opponent(player),
         opponent_board <- get_in(game_state, [opponent, :board]),
         {:ok, rules} <- Rules.check(game_state.rules, {:guess_coordinate, player}),
         {:ok, guess_coordinate} <- Coordinate.new(col: col, row: row),
         {:ok, hit_or_miss, opponent_board, forested_island, won?} <- Board.guess(opponent_board, guess_coordinate),
         {:ok, rules} <- Rules.check(rules, {:win_check, won?}) do
      game_state
      |> update_guesses(player, hit_or_miss, guess_coordinate)
      |> put_in([opponent, :board], opponent_board)
      |> put_in([:rules], rules)
      |> reply({:ok, {hit_or_miss, forested_island, won?}})
    else
      error -> reply(game_state, error)
    end
  end

  def handle_info(:timeout, game_state) do
    GameCache.delete_game(game_state.p1.name)
    {:stop, {:shutdown, :timeout}, game_state}
  end

  # internals / implementation details

  defp reply(updated_game_state, reply) do
    GameCache.store_game(updated_game_state.p1.name, updated_game_state)
    {:reply, reply, updated_game_state, @timeout}
  end

  defp opponent(:p1), do: :p2
  defp opponent(:p2), do: :p1

  defp update_guesses(game_state, player, hit_or_miss, guess_coordinate) do
    update_in(game_state, [player, :guesses], fn guesses -> Guesses.guess(hit_or_miss, guesses, guess_coordinate) end)
  end
end
