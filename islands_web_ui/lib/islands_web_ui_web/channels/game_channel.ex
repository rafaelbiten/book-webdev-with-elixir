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
      {:ok, _pid} -> {:reply, {:ok, player}, socket}
      {:error, reason} -> {:reply, {:error, inspect(reason)}, socket}
    end
  end

  # --

  def handle_in("reply", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("push", payload, socket) do
    push(socket, "push", payload)
    {:noreply, socket}
  end

  def handle_in("broadcast", payload, socket) do
    broadcast!(socket, "broadcast", payload)
    {:noreply, socket}
  end
end
