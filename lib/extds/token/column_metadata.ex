defmodule ExTds.Token.ColumnMetadata do
  @behaviour ExTds.Token.Parser

  def parse(<<0x81, _ :: binary>> = token) do
    do_parse(token, [])
  end

  defp do_parse(<<0x81, column_count :: little-size(16), tail :: binary>>, result_set) do
    with {columns, tail} <- parse_columns(tail, column_count),
         {results, tail} <- {%{columns: Enum.reverse(columns), rows: []}, tail},
      do: parse_tokens(tail, results, result_set)
  end

  # No more tokens
  defp parse_tokens(<<>>, _results, result_set), do: {result_set, <<>>}

  # Row token
  defp parse_tokens(<<0xD2, tail :: binary>>, results, result_set) do
    # Number of bytes that hold the null bits
    byte_count =
      Enum.count(results.columns) / 8
      |> Float.ceil
      |> round

    # Pull the null bits
    <<null_bits :: binary-size(byte_count), tail :: binary>> = tail
    null_columns = bits_to_array(null_bits)

    {values, tail} = parse_values(tail, results.columns, null_columns)

    results = %{results | rows: [Enum.reverse(values) | results.rows]}
    parse_tokens(tail, results, result_set)
  end

  # DONE
  defp parse_tokens(<<0xFD, _ :: binary>> = token, results, result_set) do
    {done_token, tail} = ExTds.Token.Done.parse(token)
    results = Map.put results, :row_count, done_token.row_count
    case done_token.status do
      0x10 -> {[results | result_set], tail}
      0x11 ->
        do_parse(tail, [results | result_set])
    end
  end

  defp parse_columns(tail, count), do: do_parse_columns(tail, count, [])
  defp parse_values(tail, columns, null_columns), do: do_parse_values(tail, columns, null_columns, [])

  defp do_parse_columns(tail, 0, columns), do: {columns, tail}
  defp do_parse_columns(tail, count, columns) do
    with {column, tail} <- parse_column(tail),
      do: do_parse_columns(tail, count - 1, [column | columns])
  end

  defp parse_column(<<_usertype :: little-size(4)-unit(8), _flags :: size(16), tail :: binary>>) do
    {type, tail} = ExTds.Type.Info.parse(tail)
    <<name_size :: size(8), name :: binary-size(name_size)-unit(16), tail :: binary>> = tail

    {%{name: ExTds.Utils.ucs2_to_utf(name), type: type}, tail}
  end

  # No more columns in the row
  defp do_parse_values(<<tail :: binary>>, [], _, values), do: {values, tail}

  defp do_parse_values(<<tail :: binary>>, [column | columns], [1 | null_columns], record_columns) do
    do_parse_values(tail, columns, null_columns, [nil | record_columns])
  end

  defp do_parse_values(<<tail :: binary>>, [column | columns], [_ | null_columns], record_columns) do
    {value, tail} = ExTds.Type.Value.parse(column.type, tail)

    do_parse_values(tail, columns, null_columns, [value | record_columns])
  end

  # Convert a bit array to byte array (1 for bit set, 0 for bit not set)
  defp bits_to_array(bits), do: do_bits_to_array(bits, [])

  defp do_bits_to_array(<<>>, bit_array), do: bit_array
  defp do_bits_to_array(<<byte :: binary-size(1), tail :: binary>>, bit_array) do
    bits = for <<bit::1 <- byte>>, do: bit
    bit_array = bit_array ++ Enum.reverse(bits)
    do_bits_to_array(tail, bit_array)
  end
end
