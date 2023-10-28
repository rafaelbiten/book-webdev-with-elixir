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
      {:ok, _pid} -> {:reply, :ok, socket}
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

      error ->
        {:reply, to_error(error), socket}
    end
  end

  def handle_in("position_island", payload, socket) do
    game = via(socket.topic)
    %{"player" => player, "shape" => shape, "col" => col, "row" => row} = payload

    player = String.to_existing_atom(player)
    shape = String.to_existing_atom(shape)

    case Game.position_island(game, player, shape, col, row) do
      :ok -> {:reply, :ok, socket}
      error -> {:reply, to_error(error), socket}
    end
  end

  def handle_in("set_islands", payload, socket) do
    game = via(socket.topic)
    %{"player" => player} = payload

    player = String.to_existing_atom(player)

    case Game.set_islands(game, player) do
      {:ok, board} ->
        broadcast!(socket, "islands_set", %{player: player})
        {:reply, {:ok, %{board: board}}, socket}

      error ->
        {:reply, to_error(error), socket}
    end
  end

  def handle_in("guess_coordinate", payload, socket) do
    game = via(socket.topic)
    %{"player" => player, "col" => col, "row" => row} = payload

    player = String.to_existing_atom(player)

    case Game.guess(game, player, col, row) do
      {:ok, {:hit, island, won}} ->
        result = %{hit: true, island: island, won: won}
        broadcast!(socket, "coordinate_guessed", Map.merge(payload, result))
        {:noreply, socket}

      {:ok, {:miss, island, _won}} ->
        result = %{hit: false, island: island, won: false}
        broadcast!(socket, "coordinate_guessed", Map.merge(payload, result))
        {:noreply, socket}

      error ->
        {:reply, to_error(error), socket}
    end
  end

  # --

  defp via("game:" <> player), do: GameSupervisor.find_game_by_name(player)
  defp to_error({:error, reason}), do: {:error, inspect(reason)}
  defp to_error(error), do: {:error, inspect(error)}
end
