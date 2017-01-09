defmodule ExTdsTest.ExTds.Token.Done do
  use ExUnit.Case, async: true
  alias ExTds.Token.Done

  describe "parse" do
    test "parses status and row count" do
      assert Done.parse(<<0xFD, 0x01, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>) ==
        {%Done{status: 1, row_count: 255}, <<>>}
    end
  end
end
