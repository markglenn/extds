defmodule ExTds.Connection do
  @timeout 5000

  alias ExTds.Packet.Login7
  alias ExTds.Packet.SqlBatch

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

        IO.puts "Successfully connected to SQL Server"

        %Login7{hostname: "localhost", username: "sa", password: "yourStrong(!)Password", database: "tempdb"}
        |> Login7.to_packet
        |> send_msg(0x10, sock)
        |> IO.inspect

        %SqlBatch{query: "SELECT * FROM sys.Tables"}
        |> SqlBatch.to_packet
        |> send_msg(0x01, sock)
        |> IO.inspect

        #connection
      {:error, error} ->
        {:error, error}
    end
  end

  defp send_msg(packet, type, sock) do
    IO.puts "Sending packet:"
    IO.inspect(encode_packet(packet, type))
    :ok = :gen_tcp.send(sock, encode_packet(packet, type))
    receive_response(sock)
  end

  defp receive_response(sock, body \\ <<>>) do
    case :gen_tcp.recv(sock, 0, 1000) do
      {:ok, msg} ->
        <<0x04, done, _ :: binary-size(6), tail :: binary>> = msg
        IO.puts "Received packet: "
        IO.inspect msg

        # Check if this packet is the last in a response
        case done do
          1 ->
            handle_response(body <> tail)
          0 ->
            receive_response(sock, body <> tail)
        end

      {:error, :closed} ->
        IO.inspect(:closed)
        {:error, "Connection closed"}
    end
  end

  defp handle_response(<<token_type, _length :: little-size(16), response :: binary>>) do
    case token_type do
      0xAA ->
        ExTds.Response.Error.parse(response)
      0xAD ->
        ExTds.Response.LoginAck.parse(response)
      0x81 ->
        ExTds.Response.ColumnMetadata.parse(response)
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
