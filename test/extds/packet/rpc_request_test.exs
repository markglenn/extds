defmodule ExTdsTest.ExTds.Packet.RpcRequestTest do
  use ExUnit.Case, async: true
  alias ExTds.Packet.RpcRequest

  describe "packet" do
    setup do
      transaction_id = <<0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08>> 
      %{
        connection: %ExTds.Connection{},
        transaction_connection: %ExTds.Connection{trans: transaction_id}
      }
    end

    test "with no parameters", %{transaction_connection: connection} do
      result = RpcRequest.packet(connection, :sp_prepare, [])

      assert <<
        0x16, 0x00, 0x00, 0x00,
        0x12, 0x00, 0x00, 0x00,
        0x02, 0x00,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x00, 0x00, 0x00,

        0xFF, 0xFF, 0x0A, 0x00, 0x00, 0x00>> == result
    end

    test "with single parameter", %{transaction_connection: connection} do
      parameter = %ExTds.Parameter{name: "@example", value: "test", type: :string}
      result = RpcRequest.packet(connection, :sp_prepare, [parameter])

      assert <<
        0x16, 0x00, 0x00, 0x00,
        0x12, 0x00, 0x00, 0x00,
        0x02, 0x00,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x00, 0x00, 0x00,

        0xFF, 0xFF, 0x0A, 0x00, 0x00, 0x00>> == result
    end
  end
end