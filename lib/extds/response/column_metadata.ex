defmodule ExTds.Response.ColumnMetadata do
  @behaviour ExTds.Response.Parser

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
    {type, tail} = ExTds.Type.parse(tail)
    <<name_size :: size(8), name :: binary-size(name_size)-unit(16), tail :: binary>> = tail

    IO.inspect(type)
    IO.inspect(ExTds.Utils.ucs2_to_utf(name))
    << _ :: little-size(16), tail :: binary>> = tail
    parse_column(tail)
  end
end
