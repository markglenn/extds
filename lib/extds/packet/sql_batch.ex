defmodule ExTds.Packet.SqlBatch do
  defstruct [:query]

  alias __MODULE__

  def to_packet(packet = %SqlBatch{}) do
    header = <<
      0x16 :: little-size(32), # Total header length

      0x12 :: little-size(4)-unit(8), # Transaction header size
      0x02 :: little-size(2)-unit(8), # Transaction header type
      0x00 :: little-size(8)-unit(8), # Transaction descriptor
      0x01 :: little-size(4)-unit(8), # Outstanding request count
      >>

    header <> ExTds.Utils.to_ucs2(packet.query)
  end
end
