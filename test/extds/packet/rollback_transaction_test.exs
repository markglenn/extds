defmodule ExTdsTest.ExTds.Packet.RollbackTransactionTest do
  use ExUnit.Case, async: true
  alias ExTds.Packet.RollbackTransaction

  describe "packet" do
    setup do
      transaction_id = <<0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08>> 
      %{connection: %ExTds.Connection{trans: transaction_id}}
    end

    test "creates basic transaction packet", %{connection: connection} do
      packet = RollbackTransaction.packet(connection)

      assert <<
      0x16, 0x00, 0x00, 0x00,
      0x12, 0x00, 0x00, 0x00,
      0x02, 0x00,
      0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
      0x01, 0x00, 0x00, 0x00,
      0x08, 0x00,
      0x00, 0x00
      >> == packet
    end
  end
end


