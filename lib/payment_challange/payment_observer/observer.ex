defmodule PaymentChallange.PaymentObserver.Observer do
  use GenServer
  require Logger

  alias PaymentChallange.PaymentContext, as: Context
  alias PaymentChallange.PaymentObserver.Supervisor

  @worker_interval 5000
  @log_prefix "[PaymentObserver.Observer] "

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec init(any) :: {:ok, %{}, {:continue, :observe}}
  def init(_) do
    Logger.debug(@log_prefix <> "Starting ...")
    {:ok, %{}, {:continue, :observe}}
  end

  @spec handle_continue(:observe, any) :: {:noreply, any}
  def handle_continue(:observe, state) do
    schedule()
    {:noreply, state}
  end

  @spec handle_info(:observe, any) :: {:noreply, any}
  def handle_info(:observe, state) do
    Context.get_pending_payments()
    |> Enum.each(fn {txn_hash, status} ->
      Supervisor.start_worker({txn_hash, status})
    end)

    schedule()
    {:noreply, state}
  end

  defp schedule() do
    Process.send_after(self(), :observe, @worker_interval)
  end
end
