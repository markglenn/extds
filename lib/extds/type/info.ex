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

  def parse(<<0x24, size, tail :: binary>>), do: {variable_type(:unique_identifier, :guid, size), tail}

  def parse(<<0x26, 1, tail :: binary>>), do: {variable_type(:integer, :tinyint, 1), tail}
  def parse(<<0x26, 2, tail :: binary>>), do: {variable_type(:integer, :smallint, 2), tail}
  def parse(<<0x26, 4, tail :: binary>>), do: {variable_type(:integer, :int, 4), tail}
  def parse(<<0x26, 8, tail :: binary>>), do: {variable_type(:integer, :bigint, 8), tail}

  def parse(<<0x68, size, tail :: binary>>), do: {variable_type(:boolean, :bit, size), tail}

  def parse(<<0x6F, 4, tail :: binary>>), do: {variable_type(:datetime, :smalldatetime, 4), tail}
  def parse(<<0x6F, 8, tail :: binary>>), do: {variable_type(:datetime, :datetime, 8), tail}
  def parse(<<0x28, size, tail :: binary>>), do: {variable_type(:date, :date, size), tail}
  def parse(<<0x29, size, tail :: binary>>), do: {variable_type(:time, :time, size), tail}
  def parse(<<0x2A, size, tail :: binary>>), do: {variable_type(:datetime, :datetime2, size), tail}
  def parse(<<0x2B, size, tail :: binary>>), do: {variable_type(:datetimeoffset, :datetimeoffset, size), tail}

  def parse(<<0x37, size, tail :: binary>>), do: {variable_type(:decimal, :decimal, size), tail}
  def parse(<<0x3F, size, tail :: binary>>), do: {variable_type(:decimal, :numeric, size), tail}
  def parse(<<0x6A, size, precision, scale, tail :: binary>>) do
    {
      %{
        type: :decimal,
        precision: precision,
        scale: scale,
        sqltype: :decimal,
        size: size,
        data_type: :variable
      },
      tail
    }
  end

  def parse(<<0x6C, size, precision, scale, tail :: binary>>) do
    {
      %{
        type: :decimal,
        precision: precision,
        scale: scale,
        sqltype: :numeric,
        size: size,
        data_type: :variable
      },
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

  def parse(<<0x2D, size, tail :: binary>>), do: {variable_type(:binary, :binary, size), tail}
  def parse(<<0x25, size, tail :: binary>>), do: {variable_type(:binary, :varbinary, size), tail}
  def parse(<<0xA5, size :: little-size(16), tail :: binary>>), do: {variable_type(:binary, :bigvarbinary, size), tail}
  def parse(<<0xAD, size :: little-size(16), tail :: binary>>), do: {variable_type(:binary, :bigbinary, size), tail}

  def parse(<<0xF1, size :: little-size(32), tail :: binary>>), do: {variable_type(:longstring, :xml, size), tail}
  def parse(<<0xF0, size :: little-size(16), tail :: binary>>), do: {variable_type(:binary, :udt, size), tail}
  def parse(<<0x23, size :: little-size(32), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:longstring, :text, size, collation), tail}
  def parse(<<0x63, size :: little-size(32), collation :: binary-size(5), tail :: binary>>), do: {variable_type(:longstring, :ntext, size, collation), tail}
  def parse(<<0x22, size :: little-size(32), tail :: binary>>), do: {variable_type(:binary, :image, size), tail}
  def parse(<<0x62, size :: little-size(32), tail :: binary>>), do: {variable_type(:binary, :variant, size), tail}

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
