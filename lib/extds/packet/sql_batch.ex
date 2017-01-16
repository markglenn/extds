defmodule ExTds.Packet.SqlBatch do
  defstruct [:query]

  alias ExTds.Connection

  def packet(%Connection{trans: nil}, query) do
    header = <<
      0x16 :: little-size(32), # Total header length

      0x12 :: little-size(4)-unit(8), # Transaction header size
      0x02 :: little-size(2)-unit(8), # Transaction header type
      0x00 :: little-size(8)-unit(8),
      0x01 :: little-size(4)-unit(8), # Outstanding request count
      >>

    header <> ExTds.Utils.to_ucs2(query)
  end

  def packet(%Connection{trans: transaction_id}, query) do
    header = <<
      0x16 :: little-size(32), # Total header length
      0x12 :: little-size(4)-unit(8), # Transaction header size
      0x02 :: little-size(2)-unit(8), # Transaction header type
      >> <> transaction_id <> <<
      0x01 :: little-size(4)-unit(8), # Outstanding request count
      >>

    header <> ExTds.Utils.to_ucs2(query)
  end

end
