defmodule PaymentChallange.PaymentStore do
  @moduledoc """
  Stores known payments  and their statuses
  """
  use Agent

  @store __MODULE__

  @status_pending :pending

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @store)
  end

  @spec get_status(any) :: atom() | nil
  def get_status(txn_hash) do
    if txn_exists?(txn_hash) do
      Agent.get(@store, fn txns -> txns[txn_hash].status end)
    else
      nil
    end
  end

  @spec get_block_count(any) :: integer()
  def get_block_count(txn_hash) do
    Agent.get(@store, fn txns -> txns[txn_hash].block_count end)
  end

  @spec all() :: any
  def all() do
    Agent.get(@store, &Map.to_list(&1))
  end

  @spec store(any) :: :ok
  def store(txn_hash) do
    Agent.update(__MODULE__, &Map.put(&1, txn_hash, %{status: @status_pending, block_count: nil}))
  end

  @spec store(any, any, any) :: :ok
  def store(txn_hash, status, block_count) do
    Agent.update(__MODULE__, &Map.put(&1, txn_hash, %{status: status, block_count: block_count}))
  end

  @spec update_status(any, any) :: :ok
  def update_status(txn_hash, new_status) do
    Agent.update(
      __MODULE__,
      &update_in(&1, [txn_hash, :status], fn _prevous_status -> new_status end)
    )

    :ok
  end

  @spec update_block(any, any) :: :ok
  def update_block(txn_hash, block_count) do
    Agent.update(
      __MODULE__,
      &update_in(&1, [txn_hash, :block_count], fn _prevous_count -> block_count end)
    )

    :ok
  end

  @spec reset() :: :ok
  def reset() do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  @spec txn_exists?(any) :: boolean()
  def txn_exists?(txn_hash) do
    Agent.get(@store, &Map.has_key?(&1, txn_hash))
  end

  @spec all_pending() :: any
  def all_pending() do
    Agent.get(
      @store,
      &Enum.filter(&1, fn {_txn_hash, %{status: status}} -> status == @status_pending end)
    )
  end
end
