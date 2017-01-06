defmodule ExTds.Type.Info do
  # Fixed length types
  def parse(<<0x1F, tail :: binary>>), do: {fixed_type(:nil, :null), tail}
  def parse(<<0x30, tail :: binary>>), do: {fixed_type(:integer, :tinyint), tail}
  def parse(<<0x32, tail :: binary>>), do: {fixed_type(:boolean, :bit), tail}
  def parse(<<0x34, tail :: binary>>), do: {fixed_type(:integer, :smallint), tail}
  def parse(<<0x38, tail :: binary>>), do: {fixed_type(:integer, :int), tail}
  def parse(<<0x3A, tail :: binary>>), do: {fixed_type(:datetime, :smalldatetime), tail}
  def parse(<<0x3B, tail :: binary>>), do: {fixed_type(:float, :real), tail}
  def parse(<<0x3C, tail :: binary>>), do: {fixed_type(:decimal, :money), tail}
  def parse(<<0x3D, tail :: binary>>), do: {fixed_type(:datetime, :datetime), tail}
  def parse(<<0x3E, tail :: binary>>), do: {fixed_type(:float, :float), tail}
  def parse(<<0x7A, tail :: binary>>), do: {fixed_type(:decimal, :smallmoney), tail}
  def parse(<<0x7F, tail :: binary>>), do: {fixed_type(:integer, :bigint), tail}

  def parse(<<0x24, _size, tail :: binary>>), do: {%{type: :unique_identifier, sqltype: :uuid}, tail}

  def parse(<<0x26, 1, tail :: binary>>), do: {variable_type(:integer, :tinyint, 1), tail}
  def parse(<<0x26, 2, tail :: binary>>), do: {variable_type(:integer, :smallint, 2), tail}
  def parse(<<0x26, 4, tail :: binary>>), do: {variable_type(:integer, :int, 4), tail}
  def parse(<<0x26, 8, tail :: binary>>), do: {variable_type(:integer, :bigint, 8), tail}

  def parse(<<0x68, size, tail :: binary>>), do: {variable_type(:boolean, :bit, size), tail}

  def parse(<<0x6A, _size, precision, scale, tail :: binary>>) do
    {
      %{type: :decimal, precision: precision, scale: scale, sqltype: :decimal},
      tail
    }
  end

  def parse(<<0x6C, _size, precision, scale, tail :: binary>>) do
    {
      %{type: :decimal, precision: precision, scale: scale, sqltype: :numeric},
      tail
    }
  end

  def parse(<<0x6D, 4, tail :: binary>>), do: {variable_type(:float, :float, 4), tail}
  def parse(<<0x6D, 8, tail :: binary>>), do: {variable_type(:double, :double, 8), tail}

  def parse(<<0x6E, 4, tail :: binary>>), do: {variable_type(:decimal, :smallmoney, 4), tail}
  def parse(<<0x6E, 8, tail :: binary>>), do: {variable_type(:decimal, :money, 8), tail}

  def parse(<<0x2F, size :: little-size(16), tail :: binary>>), do: {variable_type(:string, :char, size), tail}
  def parse(<<0x27, size :: little-size(16), tail :: binary>>), do: {variable_type(:string, :varchar, size), tail}
  def parse(<<0xE7, size :: little-size(16), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:string, :nvarchar, size, collation), tail}
  def parse(<<0xEF, size :: little-size(16), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:string, :nchar, size, collation), tail}
  def parse(<<0xAF, size :: little-size(16), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:string, :bigchar, size, collation), tail}
  def parse(<<0xA7, size :: little-size(16), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:string, :bigvarchar, size, collation), tail}

  defp fixed_type(type, sqltype) do
    size = cond do
      sqltype in [:null, :tinyint, :bit] -> 1
      sqltype in [:smallint] -> 2
      sqltype in [:int, :smalldatetime, :real, :smallmoney] -> 4
      true -> 8
    end

    %{data_type: :fixed, type: type, sqltype: sqltype, size: size}
  end

  defp variable_type(type, sqltype, size) do
    %{
      data_type: :variable,
      type: type,
      sqltype: sqltype,
      size: size
    }
  end
  
  defp variable_type(type, sqltype, size, <<collation :: binary>>) do
    %{
      data_type: :variable,
      type: type,
      sqltype: sqltype,
      size: size,
      collation: parse_collation(collation)
    }
  end

  defp parse_collation(<<code_page :: little-size(16), flags :: little-size(16), charset>>) do
    %{
      code_page: code_page,
      flags: flags,
      charset: charset
    }
  end
end
