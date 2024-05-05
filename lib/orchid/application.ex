defmodule Orchid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Ash.DataLayer.Mnesia.start(Orchid)

    children = [
      OrchidWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:orchid, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Orchid.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Orchid.Finch},
      # start a globally unique scheduler
      {Highlander, Orchid.Scheduler},
      # {DynamicSupervisor, name: Orchid.ServiceSupervisor, strategy: :one_for_one},
      # Start a worker by calling: Orchid.Worker.start_link(arg)
      # {Orchid.Worker, arg},
      # Start to serve requests, typically the last entry
      OrchidWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Orchid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrchidWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
