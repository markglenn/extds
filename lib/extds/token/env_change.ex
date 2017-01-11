defmodule ExTds.Token.EnvChange do
  alias ExTds.Token.Done
  alias ExTds.Connection

  defstruct [:transaction_id]

  # BEGIN TRANSACTION response
  def parse(connection, <<0xE3, _length :: little-size(16), 0x08, tail :: binary>>) do
    <<size, new_value :: binary-size(size), 0x00, tail :: binary>> = tail

    {%Done{status: 0}, _} = Done.parse(tail)

    %Connection{connection | trans: new_value}
  end

  # ROLLBACK TRANSACTION response
  def parse(connection, <<0xE3, _length :: little-size(16), 0x0A, tail :: binary>>) do
    <<0x00, size, _old_value :: binary-size(size), tail :: binary>> = tail

    {%Done{status: 0}, _} = Done.parse(tail)

    %Connection{connection | trans: nil}
  end

  # COMMIT TRANSACTION response
  def parse(connection, <<0xE3, _length :: little-size(16), 0x09, tail :: binary>>) do
    <<0x00, size, _old_value :: binary-size(size), tail :: binary>> = tail

    {%Done{status: 0}, _} = Done.parse(tail)

    %Connection{connection | trans: nil}
  end



end

