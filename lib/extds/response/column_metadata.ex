defmodule ExTds.Response.ColumnMetadata do
  @behaviour ExTds.Response.Parser
  require IEx

  alias __MODULE__

  defstruct [:count]

  def parse(response) do
    <<
      count :: little-size(2)-unit(8),
      tail :: binary
    >> = response

    parse_columns(tail, count)
  end

  defp parse_columns(tail, 0), do: []
  defp parse_columns(tail, count) do
    columns = []

    parse_column(tail)
  end

  defp parse_column(tail, 0), do: {nil, tail}
  defp parse_column(<<0, 0>>), do: nil
  defp parse_column(<<usertype::little-size(2)-unit(8), flags::size(16), tail::binary>>) do
    {type, tail} = parse_type(tail)
    <<name_size :: size(8), name :: binary-size(name_size)-unit(16), tail :: binary>> = tail

    IO.inspect(type)
    IO.inspect(ExTds.Utils.ucs2_to_utf(name))
    << _ :: little-size(16), tail :: binary>> = tail
    parse_column(tail)
  end

  # NVARCHAR
  defp parse_type(<<0xE7, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>) do
    type = %{
      type: :string,
      sqltype: :nvarchar,
      size: type_size,
      collation: parse_collation(collation)
    }

    {type, tail}
  end

  # Char
  defp parse_type(<<0xAF, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>), do: {%{type: :char}, tail}

  # Bit
  defp parse_type(<<0x32, tail :: binary>>), do: {%{type: :boolean, sqltype: :bit}, tail}
  defp parse_type(<<0x68, type_size, tail :: binary>>), do: {%{type: :boolean, sqltype: :bitntype}, tail}

  # Datetime
  defp parse_type(<<0x3D, tail :: binary>>), do: {%{type: :datetime, sqltype: :datetime}, tail}


  # INT
  defp parse_type(<<0x38, tail :: binary>>), do: {%{type: :integer, sqltype: :int}, tail}
  defp parse_type(<<0x26, size, tail :: binary>>) do
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

  defp parse_collation(<<code_page :: little-size(16), flags :: little-size(16), charset>>) do
    %{ code_page: code_page, flags: flags, charset: charset }
  end
end

