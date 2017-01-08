defmodule ExTds.Response.ColumnMetadata do
  @behaviour ExTds.Response.Parser

  alias __MODULE__

  defstruct [:count]

  def parse(response, column_count) do
    results = %{rows: []}

    {columns, tail} = parse_columns(response, column_count)
    results = Map.put(results, :columns, Enum.reverse(columns))

    {results, tail} = parse_tokens(tail, results)

    results
  end

  defp parse_tokens(<<>>, results), do: {results, <<>>}
  defp parse_tokens(<<0xD2, tail :: binary>>, results) do
    byte_count =
      Enum.count(results.columns) / 8
      |> Float.ceil
      |> round

    <<null_bits :: binary-size(byte_count), tail :: binary>> = tail
    null_columns = bits_to_array(null_bits)

    {values, tail} = parse_columns(tail, results.columns, null_columns)

    results = %{results | rows: [Enum.reverse(values) | results.rows]}
    parse_tokens(tail, results)
  end

  defp parse_tokens(<<0xFD, 0x10, 0x00, _ :: binary-size(2), count :: little-size(64), tail :: binary>>, results) do
    results = Map.put results, :count, count
    {results, tail}
  end

  defp parse_columns(tail, count) do
    do_parse_columns([], count, tail)
  end

  defp do_parse_columns(columns, 0, tail), do: {columns, tail}
  defp do_parse_columns(columns, count, tail) do
    {column, tail} = parse_column(tail)
    do_parse_columns([column | columns], count - 1, tail)
  end

  defp parse_column(<<_usertype :: little-size(4)-unit(8), _flags :: size(16), tail :: binary>>) do
    {type, tail} = ExTds.Type.Info.parse(tail)
    <<name_size :: size(8), name :: binary-size(name_size)-unit(16), tail :: binary>> = tail

    {%{name: ExTds.Utils.ucs2_to_utf(name), type: type}, tail}
  end


  defp parse_columns(<<tail :: binary>>, columns, null_columns), do: parse_columns(<<tail :: binary>>, columns, null_columns, [])

  defp parse_columns(<<tail :: binary>>, [], _null_columns, record_columns), do: {record_columns, tail}
  defp parse_columns(<<tail :: binary>>, [column | columns], [1 | null_columns], record_columns) do
    parse_columns(tail, columns, null_columns, [nil | record_columns])
  end

  defp parse_columns(<<tail :: binary>>, [column | columns], [_ | null_columns], record_columns) do
    {value, tail} = ExTds.Type.Value.parse(tail, column.type)

    parse_columns(tail, columns, null_columns, [value | record_columns])
  end

  defp bits_to_array(bits), do: bits_to_array(bits, [])
  defp bits_to_array(<<>>, bit_array), do: bit_array
  defp bits_to_array(<<byte :: binary-size(1), tail :: binary>>, bit_array) do
    bits = for <<bit::1 <- byte>>, do: bit
    bit_array = bit_array ++ Enum.reverse(bits)
    bits_to_array(tail, bit_array)
  end
end
