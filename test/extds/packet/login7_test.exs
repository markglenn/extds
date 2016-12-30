defmodule ExTdsTest.ExTds.Packet.Login7Test do
  use ExUnit.Case, async: true
  alias ExTds.Packet.Login7

  describe "encrypt_password" do
    test "encrypts single character password" do
      assert <<0xA2, 0xA5>> == Login7.encrypt_password("p") 
    end

    test "encrypts multiple character password" do
      assert <<0xE0, 0xA5, 0xF1, 0xA5, 0x90, 0xA5, 0xE0, 0xA5>> == Login7.encrypt_password("TEST")
    end
  end

  describe "to_packet" do
    test "header with username and password" do
      login_packet = %Login7{hostname: "server.example.com", username: "exampleuser", password: "password"}

      packet = Login7.to_packet(login_packet)

      # Size
      <<size :: little-size(32), tail :: binary>> = packet
      assert size == byte_size(packet)

      # TDS Version
      assert <<0x04, 0x00, 0x00, 0x74, tail :: binary>> = tail

      # Message Size
      assert <<0x00, 0x10, 0x00, 0x00, tail :: binary>> = tail

      # Client Program Version
      assert <<0x04, 0x00, 0x00, 0x07, tail :: binary>> = tail

      # Client PID
      assert <<0x00, 0x10, 0x00, 0x00, tail :: binary>> = tail

      # Connection ID
      assert <<0x00, 0x00, 0x00, 0x00, tail :: binary>> = tail

      # Option flags
      assert <<0x00, 0x00, 0x00, 0x00, tail :: binary>> = tail

      # Time zone
      assert <<0xE0, 0x01, 0x00, 0x00, tail :: binary>> = tail

      # Collation ID
      assert <<0x09, 0x04, 0x00, 0x00, _tail :: binary>> = tail
    end
  end
end

