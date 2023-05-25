defmodule PaymentChallange.PaymentControllerTest do
  use PaymentChallangeWeb.ConnCase
  alias PaymentChallange.PaymentContext
  alias PaymentChallange.PaymentStore

  setup do
    # clear store before each test
    PaymentStore.reset()
  end

  test "should return success 200 on index", %{conn: conn} do
    resp = get(conn, Routes.payment_path(conn, :index))
    assert resp.status == 200
  end

  test "should return error flash message on invalid txn_hash", %{conn: conn} do
    resp =
      post(conn, Routes.payment_path(conn, :accept_payment), %{
        "txn_hash" => "someinvalidhash"
      })

    assert resp.status == 302
    assert resp.private.phoenix_flash == %{"error" => "Probably invalid hash"}
    # no new payment should be created
    assert PaymentContext.all_payments() == []
  end

  test "should create a new entry on valid txn_hash", %{conn: conn} do
    txn_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

    # Mocking the actual scrapping is preferred but as a just test task, keeping it simple
    resp =
      post(conn, Routes.payment_path(conn, :accept_payment), %{
        "txn_hash" => txn_hash
      })

    assert resp.status == 302
    assert resp.private.phoenix_flash == %{"info" => "Sucess!!"}
    # new payment should be created
    assert [{^txn_hash, %{status: :confirmed, block_count: bcount}}] =
             PaymentContext.all_payments()

    assert bcount > 2
  end
end
