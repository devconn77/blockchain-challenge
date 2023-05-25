defmodule PaymentChallange.ScrapperTest do
  use PaymentChallangeWeb.ConnCase

  alias PaymentChallange.Scrapper

  test "should parse given valid txn_hash" do
    txn_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

    # Mocking the actual scrapping is preferred but as a just test task, keeping it simple
    assert is_integer(Scrapper.get_block_count(txn_hash))
  end

  test "should return nil given invalid valid txn_hash" do
    txn_hash = "0x7b6d0e8d812873260291c3"

    assert {:error, "Probably invalid hash"} = Scrapper.get_block_count(txn_hash)
  end
end
