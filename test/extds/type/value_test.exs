defmodule ExTdsTest.ExTds.Type.ValueTest do
  use ExUnit.Case, async: true
  alias ExTds.Type.Value

  describe "parse integer types" do
    test "parse tinyint type" do
      assert Value.parse(%{type: :integer, sqltype: :tinyint, size: 1, data_type: :fixed}, <<0x10, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :tinyint, size: 1, data_type: :fixed}, <<0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end

    test "parse smallint type" do
      assert Value.parse(%{type: :integer, sqltype: :smallint, size: 2, data_type: :fixed}, <<0x10, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :smallint, size: 2, data_type: :fixed}, <<0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end

    test "parse int type" do
      assert Value.parse(%{type: :integer, sqltype: :int, size: 4, data_type: :fixed}, <<0x10, 0x00, 0x00, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :int, size: 4, data_type: :fixed}, <<0xFF, 0xFF, 0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end
    
    test "parse bigint type" do
      assert Value.parse(%{type: :integer, sqltype: :int, size: 8, data_type: :fixed}, <<0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :int, size: 8, data_type: :fixed}, <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end

    test "parse tinyint variable type" do
      assert Value.parse(%{type: :integer, sqltype: :tinyint, size: 1, data_type: :variable}, <<0x01, 0x10, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :tinyint, size: 1, data_type: :variable}, <<0x01, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end

    test "parse smallint variable type" do
      assert Value.parse(%{type: :integer, sqltype: :smallint, size: 2, data_type: :variable}, <<0x02, 0x10, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :smallint, size: 2, data_type: :variable}, <<0x02, 0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end

    test "parse int variable type" do
      assert Value.parse(%{type: :integer, sqltype: :int, size: 4, data_type: :variable}, <<0x04, 0x10, 0x00, 0x00, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :int, size: 4, data_type: :variable}, <<0x04, 0xFF, 0xFF, 0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end
    
    test "parse bigint variable type" do
      assert Value.parse(%{type: :integer, sqltype: :int, size: 8, data_type: :variable}, <<0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>) ==
        {16, <<0x00>>}
      assert Value.parse(%{type: :integer, sqltype: :int, size: 8, data_type: :variable}, <<0x08, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00>>) ==
        {-1, <<0x00>>}
    end
  end

end
