defmodule IslandsEngine.GameSupervisor do
  @moduledoc false
  alias IslandsEngine.Game

  def start_game(player_one_name) do
    DynamicSupervisor.start_child(__MODULE__, {Game, player_one_name})
  end

  def stop_game(player_one_name) do
    player_one_name
    |> find_game_by_name()
    |> then(fn
      nil -> {:error, :game_not_found}
      game_pid -> DynamicSupervisor.terminate_child(__MODULE__, game_pid)
    end)
  end

  def find_game_by_name(player_one_name) when is_binary(player_one_name) do
    player_one_name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
