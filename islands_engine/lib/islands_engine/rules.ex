defmodule IslandsEngine.Rules do
  @moduledoc false
  alias __MODULE__

  defstruct state: :initialized,
            p1: :islands_not_set,
            p2: :islands_not_set

  def new, do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_island, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    if both_players_with_islands_set?(rules) do
      {:ok, %Rules{rules | state: :p1_turn}}
    else
      {:ok, rules}
    end
  end

  def check(%Rules{state: :p1_turn} = rules, {:guess_coordinate, :p1}) do
    {:ok, %Rules{rules | state: :p2_turn}}
  end

  def check(%Rules{state: :p2_turn} = rules, {:guess_coordinate, :p2}) do
    {:ok, %Rules{rules | state: :p1_turn}}
  end

  def check(%Rules{state: :p1_turn} = rules, {:win_check, won?}) do
    if won? do
      {:ok, %Rules{rules | state: :game_over}}
    else
      {:ok, rules}
    end
  end

  def check(%Rules{state: :p2_turn} = rules, {:win_check, won?}) do
    if won? do
      {:ok, %Rules{rules | state: :game_over}}
    else
      {:ok, rules}
    end
  end

  def check(_state, _action), do: {:error, :rule_violation}

  # implemnetation details

  defp both_players_with_islands_set?(%Rules{} = rules) do
    rules.p1 == :islands_set and rules.p2 == :islands_set
  end
end
