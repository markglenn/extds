defmodule ExTds.Packet.RpcRequest do
  alias ExTds.Connection
  import ExTds.Utils, only: [trans_id: 1]

  def packet(conn = %Connection{}, command, params) do
    encoded_params =
      params
      |> encode_params([])
      |> Enum.reverse
      |> Enum.join(<<>>)

    header(conn) <> body(command) <> encoded_params
  end

  defp header(%Connection{trans: trans}) do
    <<
      0x16 :: little-size(32), # Total header length

      0x12 :: little-size(4)-unit(8), # Transaction header size
      0x02 :: little-size(2)-unit(8) # Transaction header type
      >>
      <> trans_id(trans) <>
      <<
      0x01 :: little-size(4)-unit(8), # Outstanding request count
      >>  
  end

  defp body(:sp_prepare), do: <<0xFF, 0xFF, 0x0A :: little-size(16), 0x00, 0x00>>

  defp encode_params([], acc), do: acc
  defp encode_params([param | tail], acc) do
    encode_params(tail, [encode(param) | acc])
  end

  defp encode(_ = %ExTds.Parameter{}) do
    <<1>>
  end
end