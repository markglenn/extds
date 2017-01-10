defmodule ExTds.Token.EnvChange do
  @behaviour ExTds.Token.Parser

  alias __MODULE__
  alias ExTds.Token.Done

  defstruct [:transaction_id]

  # BEGIN TRANSACTION response
  def parse(<<0xE3, length :: little-size(16), 0x08, tail :: binary>>) do
    <<size, new_value :: binary-size(size), 0x00, tail :: binary>> = tail

    {%Done{status: 0}, tail} = Done.parse(tail)

    {%EnvChange{transaction_id: new_value}, tail}
  end

  # ROLLBACK TRANSACTION response
  def parse(<<0xE3, length :: little-size(16), 0x0A, tail :: binary>>) do
    <<0x00, size, old_value :: binary-size(size), tail :: binary>> = tail

    {%Done{status: 0}, tail} = Done.parse(tail)

    {%EnvChange{}, tail}
  end


end

