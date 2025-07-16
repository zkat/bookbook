defmodule Bookbook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @enable_ssr Application.compile_env!(:bookbook, [Bookbook.LitSSRWorker, :enable_ssr])

  @impl true
  def start(_type, _args) do
    children = [
      BookbookWeb.Telemetry,
      Bookbook.Repo,
      {DNSCluster, query: Application.get_env(:bookbook, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bookbook.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bookbook.Finch},
      # Start a worker by calling: Bookbook.Worker.start_link(arg)
      # {Bookbook.Worker, arg},
      # Start to serve requests, typically the last entry
      BookbookWeb.Endpoint,
      {Bookbook.RateLimit, clean_period: :timer.minutes(1)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bookbook.Supervisor]

    Supervisor.start_link(
      if @enable_ssr do
        children ++ [:poolboy.child_spec(:lit_ssr_worker, poolboy_config())]
      else
        children
      end,
      opts
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BookbookWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp poolboy_config do
    [
      name: {:local, :lit_ssr_worker},
      worker_module: Bookbook.LitSSRWorker,
      size: 2
    ]
  end
end
