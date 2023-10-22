defmodule ConeMediaManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ConeMediaManagerWeb.Telemetry,
      # Start the Ecto repository
      ConeMediaManager.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ConeMediaManager.PubSub},
      # Start the Oban Job scheduler
      {Oban, Application.fetch_env!(:cone_media_manager, Oban)},
      # Start the Endpoint (http/https)
      ConeMediaManagerWeb.Endpoint
      # Start a worker by calling: ConeMediaManager.Worker.start_link(arg)
      # {ConeMediaManager.Worker, arg}
    ]

    :telemetry.attach(
      "oban-errors",
      [:oban, :job, :exception],
      &ErrorReporter.handle_event/4,
      []
    )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ConeMediaManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ConeMediaManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
