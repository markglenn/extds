defmodule ExTdsTest.ExTds.Type.InfoTest do
  use ExUnit.Case, async: true
  alias ExTds.Type.Info

  describe "parse with fixed type" do
    test "parse tinyint type" do
      assert {%{type: :integer, sqltype: :tinyint, size: 1, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x30, 0x00>>)
    end

    test "parse smallint type" do
      assert {%{type: :integer, sqltype: :smallint, size: 2, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x34, 0x00>>)
    end

    test "parse int type" do
      assert {%{type: :integer, sqltype: :int, size: 4, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x38, 0x00>>)
    end

    test "parse bigint type" do
      assert {%{type: :integer, sqltype: :bigint, size: 8, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x7F, 0x00>>)
    end

    test "parse null type" do
      assert {%{type: :nil, sqltype: :null, size: 1, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x1F, 0x00>>)
    end

    test "parse bit type" do
      assert {%{type: :boolean, sqltype: :bit, size: 1, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x32, 0x00>>)
    end

    test "parse smalldatetime type" do
      assert {%{type: :datetime, sqltype: :smalldatetime, size: 4, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x3A, 0x00>>)
    end

    test "parse datetime type" do
      assert {%{type: :datetime, sqltype: :datetime, size: 8, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x3D, 0x00>>)
    end

    test "parse smallmoney type" do
      assert {%{type: :decimal, sqltype: :smallmoney, size: 4, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x7A, 0x00>>)
    end

    test "parse money type" do
      assert {%{type: :decimal, sqltype: :money, size: 8, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x3C, 0x00>>)
    end

    test "parse real type" do
      assert {%{type: :float, sqltype: :real, size: 4, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x3B, 0x00>>)
    end

    test "parse float type" do
      assert {%{type: :float, sqltype: :float, size: 8, data_type: :fixed}, <<0x00>>} ==
        Info.parse(<<0x3E, 0x00>>)
    end
  end

  describe "parse with variable numeric types" do
    test "parse tinyint variable type" do
      assert {%{type: :integer, sqltype: :tinyint, size: 1, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x26, 0x01, 0x00>>)
    end

    test "parse smallint variable type" do
      assert {%{type: :integer, sqltype: :smallint, size: 2, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x26, 0x02, 0x00>>)
    end

    test "parse int variable type" do
      assert {%{type: :integer, sqltype: :int, size: 4, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x26, 0x04, 0x00>>)
    end

    test "parse bigint variable type" do
      assert {%{type: :integer, sqltype: :bigint, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x26, 0x08, 0x00>>)
    end

    test "parse float variable type" do
      assert {%{type: :float, sqltype: :float, size: 4, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6D, 0x04, 0x00>>)
    end

    test "parse double variable type" do
      assert {%{type: :double, sqltype: :double, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6D, 0x08, 0x00>>)
    end

    test "parse smallmoney variable type" do
      assert {%{type: :decimal, sqltype: :smallmoney, size: 4, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6E, 0x04, 0x00>>)
    end

    test "parse money variable type" do
      assert {%{type: :decimal, sqltype: :money, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6E, 0x08, 0x00>>)
    end

    test "parse decimal variable type" do
      assert {%{type: :decimal, sqltype: :decimal, size: 8, precision: 14, scale: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6A, 0x08, 0x0E, 0x08, 0x00>>)
    end

    test "parse numeric variable type" do
      assert {%{type: :decimal, sqltype: :numeric, size: 8, precision: 14, scale: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6C, 0x08, 0x0E, 0x08, 0x00>>)
    end

    test "parse legacy decimal variable type" do
      assert {%{type: :decimal, sqltype: :decimal, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x37, 0x08, 0x00>>)
    end

    test "parse legacy numeric variable type" do
      assert {%{type: :decimal, sqltype: :numeric, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x3F, 0x08, 0x00>>)
    end

    test "parse GUID variable type" do
      assert {%{type: :unique_identifier, sqltype: :guid, size: 16, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x24, 0x10, 0x00>>)
    end
  end

  describe "parse with variable non-numeric types" do
    test "parse variable bit type" do
      assert {%{type: :boolean, sqltype: :bit, size: 1, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x68, 0x01, 0x00>>)
    end

    test "parse variable datetime type" do
      assert {%{type: :datetime, sqltype: :smalldatetime, size: 4, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6F, 0x04, 0x00>>)
      assert {%{type: :datetime, sqltype: :datetime, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x6F, 0x08, 0x00>>)
    end

    test "parse variable date type" do
      assert {%{type: :date, sqltype: :date, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x28, 0x08, 0x00>>)
    end

    test "parse variable time type" do
      assert {%{type: :time, sqltype: :time, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x29, 0x08, 0x00>>)
    end

    test "parse variable datetime2 type" do
      assert {%{type: :datetime, sqltype: :datetime2, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x2A, 0x08, 0x00>>)
    end

    test "parse variable datetimeoffset type" do
      assert {%{type: :datetimeoffset, sqltype: :datetimeoffset, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x2B, 0x08, 0x00>>)
    end

    test "parse variable binary type" do
      assert {%{type: :binary, sqltype: :binary, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x2D, 0x08, 0x00>>)
    end

    test "parse variable varbinary type" do
      assert {%{type: :binary, sqltype: :varbinary, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x25, 0x08, 0x00>>)
    end

    test "parse variable bigvarbinary type" do
      assert {%{type: :binary, sqltype: :bigvarbinary, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0xA5, 0x08, 0x00, 0x00>>)
    end

    test "parse variable bigbinary type" do
      assert {%{type: :binary, sqltype: :bigbinary, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0xAD, 0x08, 0x00, 0x00>>)
    end

    test "parse variable xml type" do
      assert {%{type: :longstring, sqltype: :xml, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0xF1, 0x08, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "parse variable udt type" do
      assert {%{type: :binary, sqltype: :udt, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0xF0, 0x08, 0x00, 0x00>>)
    end

    test "parse variable text type" do
      assert {%{type: :longstring, sqltype: :text, size: 8, data_type: :variable, collation: %{charset: 1, code_page: 256, flags: 257}}, <<0x00>>} ==
        Info.parse(<<0x23, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00>>)
    end

    test "parse variable ntext type" do
      assert {%{type: :longstring, sqltype: :ntext, size: 8, data_type: :variable, collation: %{charset: 1, code_page: 256, flags: 257}}, <<0x00>>} ==
        Info.parse(<<0x63, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00>>)
    end

    test "parse variable image type" do
      assert {%{type: :binary, sqltype: :image, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x22, 0x08, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "parse variable variant type" do
      assert {%{type: :binary, sqltype: :variant, size: 8, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x62, 0x08, 0x00, 0x00, 0x00, 0x00>>)
    end
  end

  describe "parse with variable string type" do
    test "parse char variable type" do
      assert {%{type: :string, sqltype: :char, size: 10, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x2F, 0x0A, 0x00, 0x00>>)
    end

    test "parse nchar variable type" do
      assert {%{type: :string, sqltype: :nchar, size: 10, data_type: :variable, collation: %{charset: 0, code_page: 0, flags: 0}}, <<0x00>>} ==
        Info.parse(<<0xEF, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "parse bigchar variable type" do
      assert {%{type: :string, sqltype: :bigchar, size: 10, data_type: :variable, collation: %{charset: 0, code_page: 0, flags: 0}}, <<0x00>>} ==
        Info.parse(<<0xAF, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "parse varchar variable type" do
      assert {%{type: :string, sqltype: :varchar, size: 10, data_type: :variable}, <<0x00>>} ==
        Info.parse(<<0x27, 0x0A, 0x00, 0x00>>)
    end

    test "parse nvarchar variable type" do
      assert {%{type: :string, sqltype: :nvarchar, size: 10, data_type: :variable, collation: %{charset: 0, code_page: 0, flags: 0}}, <<0x00>>} ==
        Info.parse(<<0xE7, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
    end

    test "parse bigvarchar variable type" do
      assert {%{type: :string, sqltype: :bigvarchar, size: 10, data_type: :variable, collation: %{charset: 0, code_page: 0, flags: 0}}, <<0x00>>} ==
        Info.parse(<<0xA7, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>)
    end
  end
end
