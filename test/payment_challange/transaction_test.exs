defmodule PaymentChallange.PaymentTest do
  use PaymentChallangeWeb.ConnCase

  alias PaymentChallange.PaymentStore

  setup do
    # clear store before each test
    PaymentStore.reset()
  end

  test "should return nil when no val exists" do
    assert is_nil(PaymentStore.get_status("someinvalidkey"))
  end

  test "should return empty lis when no payments  exists" do
    assert [] == PaymentStore.all()
  end

  test "should store with status pending when no status given" do
    PaymentStore.store("0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0")

    assert :pending =
             PaymentStore.get_status(
               "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
             )
  end

  test "should store with given status when status provided" do
    PaymentStore.store(
      "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0",
      :confirmed,
      10
    )

    assert :confirmed =
             PaymentStore.get_status(
               "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
             )

    assert 10 =
             PaymentStore.get_block_count(
               "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
             )
  end
end
