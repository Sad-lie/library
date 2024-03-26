defmodule Library.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # webhook_config = [
    #   host: "myapp.public-domain.com",
    #   port: 443,
    #   local_port: 4_000
    # ]

    # bot_config = [
    #   token: Application.fetch_env!(:library, :token_counter_bot),
    #   max_bot_concurrency: Application.fetch_env!(:library, :max_bot_concurrency)
    # ]
    children = [
      LibraryWeb.Telemetry,
      Library.Repo,
      {DNSCluster, query: Application.get_env(:library, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Library.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Library.Finch},
      # Start a worker by calling: Library.Worker.start_link(arg)
      # {Library.Worker, arg},
      # Start to serve requests, typically the last entry
      LibraryWeb.Endpoint,

      {Library.TelegramPoller, []}
      # LibraryWeb.WebhookServer,
      # {LibraryWeb.TelegramController, []}
      # {Telegram.Webhook, config: webhook_config, bots: [{Libirary.Bot, bot_config}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Library.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LibraryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
