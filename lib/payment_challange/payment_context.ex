defmodule PaymentChallange.PaymentContext do
  @moduledoc """
  Context layer for payments. Handles retrieving, filtering and updating
  of payments
  """
  alias PaymentChallange.Scrapper
  alias PaymentChallange.PaymentStore

  @status_confirmed :confirmed
  @status_pending :pending

  @doc """
  Returns all payments .
  """
  @spec all_payments :: [map()]
  def all_payments, do: PaymentStore.all()

  @doc """
  Returns status for the transaction associated with provided txn_hash.
  """
  @spec get_status_for(String.t()) :: atom()
  def get_status_for(txn_hash), do: PaymentStore.get_status(txn_hash)

  @doc """
  Returns a list of all payments with status pending.
  """
  @spec get_pending_payments() :: [map()]
  def get_pending_payments(), do: PaymentStore.all_pending()

  @doc """
  Given txn_hash and status for a payment, this function updates
  the previous status with the provided one.
  """
  @spec update_payment_block_count(String.t(), atom()) :: :ok
  def update_payment_status(txn_hash, status),
    do: PaymentStore.update_status(txn_hash, status)

  @doc """
  Given txn_hash and a block_count, this function updates the previous
  block_count with the provided one.
  """
  @spec update_payment_block_count(String.t(), integer()) :: :ok
  def update_payment_block_count(txn_hash, block_count),
    do: PaymentStore.update_block(txn_hash, block_count)

  @doc """
  Given a transaction hash, this function looks for block
  confirmations and records status accordingly.
  """
  @spec maybe_accept_payment(String.t()) :: :ok | {:error, String.t()}
  def maybe_accept_payment(txn_hash) do
    unless PaymentStore.txn_exists?(txn_hash) do
      do_accept_payment(txn_hash)
    else
      {:error,
       "Payment already exists. Its status will update momentarily, our background job is on it!"}
    end
  end

  @doc """
  Given a txn_hash, scrape it's confirmation blocks count and
  update its value in our store.
  """
  @spec maybe_update_block_count(String.t()) :: :error | :ok
  def maybe_update_block_count(txn_hash) do
    txn_hash
    |> Scrapper.get_block_count()
    |> do_maybe_update_block_count(txn_hash)
  end

  @doc """
  Returns an appropriate status for a payment, with respect to
  number of confirmation blocks. (confirmed if block_count >= 2)
  """
  @spec prepare_status(integer()) :: atom()
  def prepare_status(block_count) when block_count >= 2, do: @status_confirmed
  def prepare_status(_block_count), do: @status_pending

  defp do_maybe_update_block_count(nil, _txn_hash), do: :error

  defp do_maybe_update_block_count(count, txn_hash),
    do: update_payment_block_count(txn_hash, count)

  defp do_accept_payment(txn_hash) do
    case Scrapper.get_block_count(txn_hash) do
      num when is_integer(num) ->
        PaymentStore.store(txn_hash, prepare_status(num), num)

      error ->
        error
    end
  end
end
