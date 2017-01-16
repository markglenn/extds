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

  describe "parse booleans" do
    test "parse bit type" do
      assert Value.parse(%{type: :boolean, sqltype: :bit, size: 1, data_type: :fixed}, <<0x01, 0x00>>) ==
        {true, <<0x00>>}
      assert Value.parse(%{type: :boolean, sqltype: :bit, size: 1, data_type: :fixed}, <<0x00, 0x00>>) ==
        {false, <<0x00>>}
    end

    test "parse bit variable type" do
      assert Value.parse(%{type: :boolean, sqltype: :bit, size: 1, data_type: :variable}, <<0x01, 0x01, 0x00>>) ==
        {true, <<0x00>>}
      assert Value.parse(%{type: :boolean, sqltype: :bit, size: 1, data_type: :variable}, <<0x01, 0x00, 0x00>>) ==
        {false, <<0x00>>}
      assert Value.parse(%{type: :boolean, sqltype: :bit, size: 1, data_type: :variable}, <<0x00, 0x00>>) ==
        {nil, <<0x00>>}
    end
  end

  describe "parse decimal" do
    test "parse smallmoney" do
      assert Value.parse(%{sqltype: :smallmoney, data_type: :fixed}, <<0x01, 0x00, 0x00, 0x00, 0x00>>) ==
        {0.0001, <<0x00>>}
    end

    test "parse money" do
      assert Value.parse(%{sqltype: :money, data_type: :fixed}, <<0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>) ==
        {0.0001, <<0x00>>}
    end

    test "parse variable money" do
      assert Value.parse(%{sqltype: :money, data_type: :variable}, <<0x04, 0x01, 0x00, 0x00, 0x00, 0x00>>) ==
        {0.0001, <<0x00>>}
      assert Value.parse(%{sqltype: :money, data_type: :variable}, <<0x08, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>) ==
        {0.0001, <<0x00>>}
    end

    test "parse decimal"
    test "parse variable decimal"
    test "parse numeric"
    test "parse real"
    test "parse float"
    test "parse double"
  end

  describe "parse dates and times" do
    test "parse smalldatetime"
    test "parse datetime"
    test "parse variable datetime"
    test "parse variable datetimeoffset"
    test "parse date"
    test "parse time"
    test "parse datetime2"
  end

  describe "parse strings" do
    test "parse char" do
      assert Value.parse(%{type: :string, sqltype: :char, size: 4, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse varchar" do
      assert Value.parse(%{type: :string, sqltype: :varchar, size: 4, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse nchar" do
      assert Value.parse(%{type: :string, sqltype: :nchar, size: 4, data_type: :variable}, <<0x02, 0x00, 0x41, 0x00, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse nvarchar" do
      assert Value.parse(%{type: :string, sqltype: :nvarchar, size: 4, data_type: :variable}, <<0x02, 0x00, 0x41, 0x00, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse bigchar" do
      assert Value.parse(%{type: :string, sqltype: :bigchar, size: 4, data_type: :variable}, <<0x02, 0x00, 0x41, 0x00, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse bigvarchar" do
      assert Value.parse(%{type: :string, sqltype: :bigvarchar, size: 4, data_type: :variable}, <<0x02, 0x00, 0x41, 0x00, 0x00>>) ==
        {"A", <<0x00>>}
    end
  end

  describe "parse binary" do
    test "parse binary" do
      assert Value.parse(%{type: :binary, sqltype: :binary, size: 1, data_type: :variable}, <<0x01, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse varbinary" do
      assert Value.parse(%{type: :binary, sqltype: :varbinary, size: 1, data_type: :variable}, <<0x01, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse big binary" do
      assert Value.parse(%{type: :binary, sqltype: :bigbinary, size: 1, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse big varbinary" do
      assert Value.parse(%{type: :binary, sqltype: :bigvarbinary, size: 1, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse xml" do
      assert Value.parse(%{type: :binary, sqltype: :xml, size: 1, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse udt" do
      assert Value.parse(%{type: :binary, sqltype: :udt, size: 1, data_type: :variable}, <<0x01, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse image" do
      assert Value.parse(%{type: :binary, sqltype: :image, size: 1, data_type: :variable}, <<0x01, 0x00, 0x00, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse variant" do
      assert Value.parse(%{type: :binary, sqltype: :variant, size: 1, data_type: :variable}, <<0x01, 0x00, 0x00, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse text" do
      assert Value.parse(%{type: :binary, sqltype: :text, size: 1, data_type: :variable}, <<0x01, 0x00, 0x00, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse ntext" do
      assert Value.parse(%{type: :binary, sqltype: :ntext, size: 1, data_type: :variable}, <<0x01, 0x00, 0x00, 0x00, 0x41, 0x00>>) ==
        {"A", <<0x00>>}
    end

    test "parse unique_identifier" do
      assert Value.parse(%{type: :unique_identifier, data_type: :variable}, <<0x10, 0x01, 0x02, 0x03, 0x04,
                         0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x00>>) ==
        {<<0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,
          0x0D, 0x0E, 0x0F, 0x10>>, <<0x00>>}

      assert Value.parse(%{type: :unique_identifier, data_type: :variable}, <<0x00, 0x00>>) ==
        {nil, <<0x00>>}
    end
  end
end
