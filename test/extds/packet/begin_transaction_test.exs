defmodule ExTdsTest.ExTds.Packet.BeginTransactionTest do
  use ExUnit.Case, async: true
  alias ExTds.Packet.BeginTransaction

  describe "packet" do
    test "creates basic transaction packet" do
      packet = BeginTransaction.packet(%{})

      assert <<
      0x16, 0x00, 0x00, 0x00,
      0x12, 0x00, 0x00, 0x00,
      0x02, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x01, 0x00, 0x00, 0x00,
      0x05, 0x00,
      0x00, 0x00
      >> == packet
    end
  end
end
