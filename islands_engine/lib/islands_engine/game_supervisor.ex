defmodule IslandsEngine.GameSupervisor do
  @moduledoc false
  alias IslandsEngine.Game

  def start_game(player_one_name) do
    DynamicSupervisor.start_child(__MODULE__, {Game, player_one_name})
  end

  def find_game_by_name(player_one_name) when is_binary(player_one_name) do
    player_one_name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
