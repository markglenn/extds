defmodule ExTds.Token.Done do
  @behaviour ExTds.Token.Parser

  alias __MODULE__

  defstruct [:status, :row_count]

  def parse(<<0xFD, status :: little-size(16), _ :: binary-size(2), row_count :: little-size(64), tail :: binary>>) do
    {
      %Done{
        status: status,
        row_count: row_count
      },
      tail
    }
  end
end
