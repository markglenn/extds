defmodule ExTdsTest.ExTds.Packet.Login do
  use ExUnit.Case, async: true
  alias ExTds.Packet.Login

  describe "encrypt_password" do
    test "encrypts single character password" do
      assert <<0xA2, 0xA5>> == Login.encrypt_password("p") 
    end

    test "encrypts multiple character password" do
      assert <<0xE0, 0xA5, 0xF1, 0xA5, 0x90, 0xA5, 0xE0, 0xA5>> == Login.encrypt_password("TEST")
    end
  end
end

