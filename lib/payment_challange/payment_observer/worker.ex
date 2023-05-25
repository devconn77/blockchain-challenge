defmodule PaymentChallange.PaymentObserver.Worker do
  use GenServer
  require Logger
  alias PaymentChallange.Scrapper
  alias PaymentChallange.PaymentContext, as: Context

  @log_prefix "[PaymentChallange.PaymentObserver.Worker] "

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    Logger.info(@log_prefix <> "Starting with opts: #{inspect(opts)}")
    GenServer.start_link(__MODULE__, opts)
  end

  @spec init(any) :: {:ok, any, {:continue, :scrape_and_update}}
  def init(opts) do
    Logger.debug(@log_prefix <> "Starting ...")
    {:ok, opts, {:continue, :scrape_and_update}}
  end

  @spec handle_continue(:scrape_and_update, {String.t(), atom()}) :: {:stop, :normal, any()}
  def handle_continue(:scrape_and_update, {txn_hash, status} = state) do
    case do_scrape_and_update(txn_hash, status) do
      :no_change ->
        Logger.debug(
          @log_prefix <> " No change in status for txn_hash: #{txn_hash}, status: #{status}"
        )

      :ok ->
        Logger.debug(
          @log_prefix <> " Change in status for txn_hash: #{txn_hash}, previous status: #{status}"
        )
    end

    {:stop, :normal, state}
  end

  defp do_scrape_and_update(txn_hash, previous_status) do
    block_count = Scrapper.get_block_count(txn_hash)

    block_count
    |> Context.prepare_status()
    |> maybe_update_status(txn_hash, previous_status)
    |> maybe_update_block_count(txn_hash, block_count)
  end

  defp maybe_update_status(current_status, _txn_hash, previous_status)
       when current_status == previous_status,
       do: :no_change

  defp maybe_update_status(current_status, txn_hash, _previous_status) do
    Context.update_payment_status(txn_hash, current_status)
    :ok
  end

  defp maybe_update_block_count(:no_change, _, _), do: :no_change
  defp maybe_update_block_count(:ok, txn_hash, block_count) do
    Context.update_payment_block_count(txn_hash, block_count)
    :ok

  end
end
