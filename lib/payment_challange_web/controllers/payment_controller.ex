defmodule PaymentChallangeWeb.PaymentController do
  use PaymentChallangeWeb, :controller

  alias PaymentChallange.PaymentContext

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    all_payments = PaymentContext.all_payments()
    render(conn, "index.html", payments: all_payments)
  end

  @spec accept_payment(Plug.Conn.t(), map) :: Plug.Conn.t()
  def accept_payment(conn, %{"txn_hash" => txn_hash} = _params) do
    with :ok <- PaymentContext.maybe_accept_payment(txn_hash) do
      conn
      |> put_flash(:info, "Sucess!!")
      |> redirect(to: Routes.payment_path(conn, :index))
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.payment_path(conn, :index))
    end
  end

  @spec update_block_count(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update_block_count(conn, %{"txn_hash" => txn_hash}) do
    with :ok <- PaymentContext.maybe_update_block_count(txn_hash) do
      conn
      |> put_flash(:info, "Sucess!!")
      |> redirect(to: Routes.payment_path(conn, :index))
    else
      _error ->
        conn
        |> put_flash(:error, "ERROR!! Probably an invalid txn_hash")
        |> redirect(to: Routes.payment_path(conn, :index))
    end
  end
end
