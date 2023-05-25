defmodule PaymentChallange.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PaymentChallangeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentChallange.PubSub},
      # Start the Endpoint (http/https)
      PaymentChallangeWeb.Endpoint,
      PaymentChallange.PaymentStore,
      PaymentChallange.PaymentObserver.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentChallange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaymentChallangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
