defmodule ExTdsTest.ExTds.Packet.SqlBatchTest do
  use ExUnit.Case, async: true
  alias ExTds.Packet.SqlBatch

  describe "packet" do
    setup do
      transaction_id = <<0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08>> 
      %{
        connection: %ExTds.Connection{},
        transaction_connection: %ExTds.Connection{trans: transaction_id}
      }
    end

    test "creates basic query packet", %{connection: connection} do
      packet = SqlBatch.packet(connection, "SELECT 1")

      assert <<
        0x16, 0x00, 0x00, 0x00,
        0x12, 0x00, 0x00, 0x00,
        0x02, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00,
        83, 0, 69, 0, 76, 0, 69, 0, 67, 0, 84, 0, 32, 0, 49, 0>> == packet
    end
    
    test "creates basic query packet with transaction", %{transaction_connection: connection} do
      packet = SqlBatch.packet(connection, "SELECT 1")

      assert <<
        0x16, 0x00, 0x00, 0x00,
        0x12, 0x00, 0x00, 0x00,
        0x02, 0x00,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x00, 0x00, 0x00,
        83, 0, 69, 0, 76, 0, 69, 0, 67, 0, 84, 0, 32, 0, 49, 0>> == packet
    end
  end
end



