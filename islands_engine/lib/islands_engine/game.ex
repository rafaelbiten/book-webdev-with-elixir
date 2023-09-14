defmodule IslandsEngine.Game do
  @moduledoc false
  use GenServer

  alias IslandsEngine.Impl.Board
  alias IslandsEngine.Impl.Guesses
  alias IslandsEngine.Rules

  # client

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    new_game = %{player1: player1, player2: player2, rules: %Rules{}}
    {:ok, new_game}
  end

  # 2 aliases to get the game state
  defdelegate get_state(game), to: :sys
  defdelegate state(game), to: :sys, as: :get_state

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  # server

  def handle_call({:add_player, name}, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, :add_player) do
      game_state
      |> put_in([:player2, :name], name)
      |> put_in([:rules], rules)
      |> reply(:ok)
    else
      :error -> reply(game_state, :error)
    end
  end

  # internals / implementation details

  defp reply(updated_game_state, reply), do: {:reply, reply, updated_game_state}
end
