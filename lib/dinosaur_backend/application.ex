defmodule DinosaurBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DinosaurBackendWeb.Telemetry,
      DinosaurBackend.Repo,
      {DNSCluster, query: Application.get_env(:dinosaur_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DinosaurBackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: DinosaurBackend.Finch},
      # Start a worker by calling: DinosaurBackend.Worker.start_link(arg)
      # {DinosaurBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      DinosaurBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DinosaurBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DinosaurBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
