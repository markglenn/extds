defmodule ExTds.Packet.CommitTransaction do
  alias ExTds.Connection

  def packet(%Connection{trans: transaction_id}) do
    header = <<
      0x12 :: little-size(32), # Transaction header size
      0x02 :: little-size(16), # Transaction header type
      >> <> transaction_id <> <<
      0x01 :: little-size(32), # Outstanding request count
      >>

    <<0x16 :: little-size(32)>> <>
      header <> <<0x07 :: little-size(16), 0x00 :: little-size(16)>>
  end
end

