defmodule IslandsEngine.GameSupervisor do
  @moduledoc false
  alias IslandsEngine.Game

  def start_game(player_one_name) do
    DynamicSupervisor.start_child(__MODULE__, {Game, player_one_name})
  end

  def find_game_by_name(player_one_name) do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.filter(&child_pid?/1)
    |> Enum.find_value(&find_game(&1, player_one_name))
  end

  defp find_game(child, player_one_name) do
    with {:undefined, game_pid, :worker, [Game]} <- child,
         game_state <- Game.state(game_pid),
         true <- game_state.p1.name == player_one_name do
      game_pid
    else
      _ -> nil
    end
  end

  defp child_pid?({:undefined, child_pid, :worker, [Game]}) when is_pid(child_pid) do
    true
  end

  defp child_pid?(_child) do
    false
  end
end
