defmodule ExTds.Packet.SqlBatch do
  defstruct [:query]

  import ExTds.Utils, only: [trans_id: 1]
  alias ExTds.Connection

  def packet(%Connection{trans: trans}, query) do
    header = <<
      0x16 :: little-size(32), # Total header length

      0x12 :: little-size(4)-unit(8), # Transaction header size
      0x02 :: little-size(2)-unit(8) # Transaction header type
      >>
      <> trans_id(trans) <>
      <<
      0x01 :: little-size(4)-unit(8), # Outstanding request count
      >>

    header <> ExTds.Utils.to_ucs2(query)
  end
end
