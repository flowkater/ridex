defmodule RidexServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RidexServer.Repo,
      # Start the Telemetry supervisor
      RidexServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RidexServer.PubSub},
      # Start the Endpoint (http/https)
      RidexServerWeb.Endpoint
      # Start a worker by calling: RidexServer.Worker.start_link(arg)
      # {RidexServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RidexServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RidexServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
