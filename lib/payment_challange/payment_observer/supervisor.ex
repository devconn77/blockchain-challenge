defmodule PaymentChallange.PaymentObserver.Supervisor do
  use Supervisor
  alias PaymentChallange.PaymentObserver.Observer
  alias PaymentChallange.PaymentObserver.Worker

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any) :: {:ok, tuple()}
  def init(_args) do
    children = [
      Observer,
      {DynamicSupervisor,
       strategy: :one_for_one, name: PaymentChallange.PaymentObserver.DynamicSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec start_worker({String.t(), %{:status => atom()}}) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_worker({txn_hash, %{status: status}}) do
    worker_spec = {Worker, {txn_hash, status}}

    DynamicSupervisor.start_child(PaymentChallange.PaymentObserver.DynamicSupervisor, worker_spec)
  end
end
