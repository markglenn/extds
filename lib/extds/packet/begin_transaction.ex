defmodule ExTds.Packet.BeginTransaction do
  def to_packet() do
    header = <<
      0x12 :: little-size(32), # Transaction header size
      0x02 :: little-size(16), # Transaction header type
      0x00 :: little-size(64), # Transaction descriptor
      0x01 :: little-size(32), # Outstanding request count
      >>

    <<0x16 :: little-size(32)>> <>
      header <> <<0x05 :: little-size(16), 0x00 :: little-size(16)>>
  end
end
