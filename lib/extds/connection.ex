defmodule ExTds.Connection do
  @timeout 5000
  alias ExTds.Packet.Login7

  require IEx

  defstruct [
    sock: nil
  ]

  def connect do
    connection = %ExTds.Connection{}

    host = String.to_char_list("localhost")
    sock_opts = [
      {:active, false},
      :binary,
      {:packet, :raw},
      {:delay_send, false}
    ]

    case :gen_tcp.connect(host, 1433, sock_opts, @timeout) do
      {:ok, sock} ->
        connection = %ExTds.Connection{connection | sock: sock}

        packet =
          %Login7{hostname: "localhost", username: "sa", password: "yourStrong(!)Password", database: "tempdb"}
          |> Login7.to_packet
          |> encode_packet(0x10)

        :gen_tcp.send(sock, packet)

        {:ok, msg} = :gen_tcp.recv(sock, 0)

        handle_response(msg)
        #connection
      {:error, error} ->
        {:error, error}
    end
  end

  defp handle_response(<<0x04, 0x01, _packet_size :: little-size(16), _unknown :: little-size(32), type, _length :: little-size(16), response :: binary>>) do
    case type do
      0xAA ->
        ExTds.Response.Error.parse(response)
      0xAD ->
        ExTds.Response.LoginAck.parse(response)
    end
  end

  defp encode_packet(packet, type) do
    header = <<
      type,
      1, # Status
      byte_size(packet) + 8 :: size(16), # Packet length
      0 :: size(16),
      1, # ID
      0
    >>

    header <> packet
  end

end
