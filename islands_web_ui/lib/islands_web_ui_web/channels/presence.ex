defmodule IslandsWebUiWeb.Presence do
  use Phoenix.Presence,
    otp_app: :islands_web_ui,
    pubsub_server: IslandsWebUi.PubSub
end
