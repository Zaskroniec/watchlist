defmodule Watchlist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WatchlistWeb.Telemetry,
      Watchlist.Repo,
      {DNSCluster, query: Application.get_env(:watchlist, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Watchlist.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Watchlist.Finch},
      # Start a worker by calling: Watchlist.Worker.start_link(arg)
      # {Watchlist.Worker, arg},
      # Start to serve requests, typically the last entry
      WatchlistWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Watchlist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WatchlistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
