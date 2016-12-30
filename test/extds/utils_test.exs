defmodule ExTdsTest.ExTds.UtilsTest do
  use ExUnit.Case, async: true
  alias ExTds.Utils

  describe "to_ucs2" do
    test "convert blank string" do
      assert <<>> == Utils.to_ucs2("")
    end

    test "convert test string" do
      assert <<0x54, 0x00, 0x45, 0x00, 0x53, 0x00, 0x54, 0x00>> == Utils.to_ucs2("TEST")
    end
  end

  describe "ucs2_to_utf" do
    test "convert blank string" do
      assert "" == Utils.ucs2_to_utf(<<>>)
    end

    test "convert test string" do
      assert "TEST" == Utils.ucs2_to_utf(<<0x54, 0x00, 0x45, 0x00, 0x53, 0x00, 0x54, 0x00>>)
    end

    test "convert back and forth" do
      assert "TEST" == Utils.ucs2_to_utf(Utils.to_ucs2("TEST"))
    end
  end
end
