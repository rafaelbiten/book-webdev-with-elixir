defmodule IslandsWebUi.Socket do
  use Phoenix.Socket

  channel "game:*", IslandsWebUiWeb.GameChannel
end
