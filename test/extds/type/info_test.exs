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
