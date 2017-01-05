defmodule ExTds.Response.ColumnMetadata do
  @behaviour ExTds.Response.Parser

  alias __MODULE__

  defstruct [:count]

  def parse(response, column_count) do
    <<
      _ek_value_count :: binary-size(2)-unit(8),
      tail :: binary
    >> = response

    parse_columns(tail, column_count)
  end

  defp parse_columns(tail, 0), do: []
  defp parse_columns(tail, count) do
    columns = []

    parse_column(tail, count)
  end

  defp parse_column(_, 0), do: {}
  defp parse_column(<<usertype :: little-size(2)-unit(8), flags::size(16), tail::binary>> = r, count) do
    {type, tail} = ExTds.Type.parse(tail)
    <<name_size :: size(8), name :: binary-size(name_size)-unit(16), tail :: binary>> = tail

    << _ :: little-size(16), tail :: binary>> = tail
    parse_column(tail, count - 1)
  end
end
