defmodule ExTds.Type do
  alias __MODULE__

  # Fixed length types
  def parse(<<0x1F, tail :: binary>>), do: {%{type: :null,      sqltype: :null},          tail}
  def parse(<<0x30, tail :: binary>>), do: {%{type: :integer,   sqltype: :tinyint},       tail}
  def parse(<<0x32, tail :: binary>>), do: {%{type: :boolean,   sqltype: :bit},           tail}
  def parse(<<0x34, tail :: binary>>), do: {%{type: :integer,   sqltype: :smallint},      tail}
  def parse(<<0x38, tail :: binary>>), do: {%{type: :integer,   sqltype: :int},           tail}
  def parse(<<0x3A, tail :: binary>>), do: {%{type: :datetime,  sqltype: :smalldatetime}, tail}
  def parse(<<0x3B, tail :: binary>>), do: {%{type: :float,     sqltype: :real},          tail}
  def parse(<<0x3C, tail :: binary>>), do: {%{type: :decimal,   sqltype: :money},         tail}
  def parse(<<0x3D, tail :: binary>>), do: {%{type: :datetime,  sqltype: :datetime},      tail}
  def parse(<<0x3E, tail :: binary>>), do: {%{type: :float,     sqltype: :float},         tail}
  def parse(<<0x7A, tail :: binary>>), do: {%{type: :decimal,   sqltype: :smallmoney},    tail}
  def parse(<<0x7F, tail :: binary>>), do: {%{type: :integer,   sqltype: :bigint},        tail}

  def parse(<<0x26, size, tail :: binary>>) do
    sqltype = case size do
      1 -> :tinyint
      2 -> :smallint
      4 -> :int
      8 -> :bigint
    end

    type = %{
      type: :integer,
      sqltype: sqltype
    }

    {type, tail}
  end

  def parse(<<0x68, _size, tail :: binary>>), do: {%{type: :boolean, sqltype: :bitntype}, tail}

  def parse(<<0xAF, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>) do
    {
      %{type: :string, sqltype: :char, size: type_size},
      tail
    }
  end

  def parse(<<0xE7, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>) do
    type = %{
      type: :string,
      sqltype: :nvarchar,
      size: type_size,
      collation: parse_collation(collation)
    }

    {type, tail}
  end

  defp parse_collation(<<code_page :: little-size(16), flags :: little-size(16), charset>>) do
    %{ code_page: code_page, flags: flags, charset: charset }
  end
end
