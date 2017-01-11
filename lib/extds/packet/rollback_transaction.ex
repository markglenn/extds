defmodule ExTds.Packet.RollbackTransaction do
  alias ExTds.Connection

  def packet(%Connection{trans: nil}), do: {:error, "Tried to rollback a transaction with no open transaction"}
  def packet(%Connection{trans: transaction_id}) do
    header = <<0x12 :: little-size(32), 0x02 :: little-size(16)>>
      <> transaction_id
      <> <<0x01 :: little-size(32)>>

    <<0x16 :: little-size(32)>>
      <> header
      <> <<0x08 :: little-size(16), 0x00 :: little-size(16)>>
  end
end

