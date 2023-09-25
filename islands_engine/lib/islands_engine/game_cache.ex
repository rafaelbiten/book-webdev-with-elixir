defmodule IslandsEngine.GameCache do
  @moduledoc false
  use GenServer

  # client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def store_game(key, value) do
    GenServer.cast(__MODULE__, {:store_game, key, value})
  end

  def restore_game(key) do
    GenServer.call(__MODULE__, {:restore_game, key})
  end

  def delete_game(key) do
    GenServer.cast(__MODULE__, {:delete_game, key})
  end

  # server

  def init(:ok) do
    game_cache_table = :ets.new(:game_cache, [:named_table])
    {:ok, game_cache_table}
  end

  def handle_cast({:store_game, key, value}, game_cache_table) do
    :ets.insert(game_cache_table, {key, value})
    {:noreply, game_cache_table}
  end

  def handle_cast({:delete_game, key}, game_cache_table) do
    :ets.delete(game_cache_table, key)
    {:noreply, game_cache_table}
  end

  def handle_call({:restore_game, key}, _from, game_cache_table) do
    reply =
      case :ets.lookup(game_cache_table, key) do
        [] -> nil
        [{_key, value}] -> value
      end

    {:reply, reply, game_cache_table}
  end
end
