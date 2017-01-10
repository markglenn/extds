defmodule ExTds.Connection do
  @timeout 5000

  alias ExTds.Packet.Login7
  alias ExTds.Packet.SqlBatch
  alias ExTds.Packet.BeginTransaction
  alias ExTds.Packet.RollbackTransaction
  alias ExTds.Packet.CommitTransaction

  defstruct [:sock, :trans]

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

        # A suitable :buffer is only set if :recbuf is included in
        # :socket_options.
        {:ok, [sndbuf: sndbuf, recbuf: recbuf, buffer: buffer]} =
          :inet.getopts(sock, [:sndbuf, :recbuf, :buffer])

        buffer =
          buffer
          |> max(sndbuf)
          |> max(recbuf)

        :ok = :inet.setopts(sock, buffer: buffer)

        IO.puts "Successfully connected to SQL Server"

        %Login7{hostname: "localhost", username: "sa", password: "yourStrong(!)Password", database: "tempdb"}
        |> Login7.to_packet
        |> send_msg(0x10, connection)
        |> IO.inspect

        connection =
          connection
          |> BeginTransaction.to_packet
          |> send_msg(0x0E, connection)

        connection
        |> SqlBatch.to_packet(%SqlBatch{query: "SELECT * FROM sys.tables; SELECT * FROM sys.Columns"})
        |> send_msg(0x01, connection)
        |> IO.inspect

        connection
        |> CommitTransaction.to_packet
        |> send_msg(0x0E, connection)
        |> IO.inspect

        :gen_tcp.close(sock)
        #connection
      {:error, error} ->
        {:error, error}
    end
  end

  defp send_msg(packet, type, connection) do
    IO.puts "Sending packet:"
    IO.inspect(encode_packet(packet, type))
    :ok = :gen_tcp.send(connection.sock, encode_packet(packet, type))

    receive_response(connection)
  end

  defp receive_response(connection, packets \\ []) do
    case receive_packet(connection.sock) do
      {:ok, <<0x04, 0x01, _ :: binary-size(6), tail :: binary>>} ->
        [tail | packets ]
        |> Enum.reverse
        |> Enum.join(<<>>)
        |> handle_response(connection)
      {:ok, <<0x04, 0x00, _ :: binary-size(6), tail :: binary>>} ->
        receive_response(connection, [tail | packets])
    end
  end

  defp receive_packet(sock, body \\ <<>>) do
    case :gen_tcp.recv(sock, 0, 1000) do

      {:ok, <<msg :: binary>>} ->
        case body <> msg do
          # Packet contains the header at least
          <<_ :: binary-size(2), size :: size(16), _ :: binary-size(4), tail :: binary>> = msg ->
            size = size - 8

            # Make sure we received the full packet
            case tail do
              <<_ :: binary-size(size)>> -> {:ok, msg}
              _ -> receive_packet(sock, msg)
            end

          # Packet is not large enough to even contain the header
          <<msg :: binary>> -> receive_packet(sock, msg)
        end

      {:error, :closed} ->
        IO.inspect(:closed)
        {:error, "Connection closed"}
    end
  end

  defp handle_response(<<token_type, _length :: little-size(16), response :: binary>> = msg, connection) do
    IO.puts "Received packet:"
    IO.inspect(msg)

    case token_type do
      0xAA ->
        ExTds.Token.Error.parse(connection, response)
      0xAD ->
        ExTds.Token.LoginAck.parse(connection, response)
      0x81 ->
        ExTds.Token.ColumnMetadata.parse(connection, msg)
      0xE3 ->
        ExTds.Token.EnvChange.parse(connection, msg)
    end
  end

  defp encode_packet(packet, type) do
    header = <<type, 1, byte_size(packet) + 8 :: size(16), 0 :: size(16), 1, 0>>
    header <> packet
  end
end
