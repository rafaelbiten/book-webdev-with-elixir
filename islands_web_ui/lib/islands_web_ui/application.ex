defmodule IslandsWebUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IslandsWebUiWeb.Telemetry,
      {Phoenix.PubSub, name: IslandsWebUi.PubSub},
      IslandsWebUiWeb.Presence,
      {Finch, name: IslandsWebUi.Finch},
      IslandsWebUiWeb.Endpoint
      # Start a worker by calling: IslandsWebUi.Worker.start_link(arg)
      # {IslandsWebUi.Worker, arg}
      # IslandsEngine.Application
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IslandsWebUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IslandsWebUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
