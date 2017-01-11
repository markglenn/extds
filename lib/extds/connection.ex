defmodule ExTds.Connection do
  @timeout 5000

  alias __MODULE__

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

        %Login7{hostname: "localhost", username: "sa", password: "yourStrong(!)Password", database: "tempdb"}
        |> Login7.packet
        |> send_msg(0x10, connection)

        {:ok, connection}
      {:error, error} ->
        {:error, error}
    end
  end

  def disconnect(%Connection{sock: sock}) do
    :ok = :gen_tcp.close(sock)

    {:ok, %Connection{}}
  end

  def begin_transaction(conn = %Connection{}) do
    conn =
      conn
      |> BeginTransaction.packet
      |> send_msg(0x0E, conn)

    {:ok, conn}
  end

  def rollback_transaction(conn = %Connection{}) do
    conn =
      conn
      |> RollbackTransaction.packet
      |> send_msg(0x0E, conn)

    {:ok, conn}
  end

  def commit_transaction(conn = %Connection{}) do
    conn =
      conn
      |> CommitTransaction.packet
      |> send_msg(0x0E, conn)

    {:ok, conn}
  end

  def execute_raw(conn = %Connection{}, sql) do
    results =
      conn
      |> SqlBatch.packet(sql)
      |> send_msg(0x01, conn)

    {:ok, results, conn}
  end

  defp send_msg(packet, type, connection) do
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
    case token_type do
      0xAA ->
        ExTds.Token.Error.parse(connection, response)
      0xAD ->
        ExTds.Token.LoginAck.parse(connection, response)
      0x81 ->
        ExTds.Token.ColumnMetadata.parse(connection, msg)
      0xE3 ->
        ExTds.Token.EnvChange.parse(connection, msg)
      _ ->
        IO.puts "Received unknown packet:"
        IO.inspect(msg)
    end
  end

  defp encode_packet(packet, type) do
    header = <<type, 1, byte_size(packet) + 8 :: size(16), 0 :: size(16), 1, 0>>
    header <> packet
  end
end
