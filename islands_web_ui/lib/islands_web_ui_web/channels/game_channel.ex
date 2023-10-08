defmodule IslandsWebUiWeb.GameChannel do
  use IslandsWebUiWeb, :channel

  alias IslandsEngine.Game
  alias IslandsEngine.GameSupervisor

  def join("game:" <> _player, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("start_game", _payload, socket) do
    "game:" <> player = socket.topic

    case GameSupervisor.start_game(player) do
      {:ok, _pid} -> {:reply, {:ok, %{player: player}}, socket}
      {:error, reason} -> {:reply, {:error, inspect(reason)}, socket}
    end
  end

  def handle_in("add_player", player, socket) do
    socket.topic
    |> via()
    |> Game.add_player(player)
    |> case do
      :ok ->
        broadcast!(socket, "player_added", %{
          player: player,
          message: "A second player joined the game: " <> player
        })

        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, inspect(reason)}, socket}

      error ->
        {:reply, {:error, inspect(error)}, socket}
    end
  end

  # --

  defp via("game:" <> player), do: GameSupervisor.find_game_by_name(player)
end
