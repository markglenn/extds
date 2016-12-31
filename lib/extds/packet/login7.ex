defmodule ExTds.Packet.Login7 do
  # https://msdn.microsoft.com/en-us/library/dd304019.aspx

  defstruct [:hostname, :username, :password, :database]

  use Bitwise
  alias ExTds.Utils

  def encrypt_password(password) do
    password
    |> Utils.to_ucs2
    |> :binary.bin_to_list
    |> Enum.map(fn b ->
      # Swap the top and bottom nibbles 
      <<x::size(4), y::size(4)>> = <<b>>
      <<c>> = <<y::size(4), x::size(4)>>

      Bitwise.bxor(c, 0xA5)
    end)
    |> :binary.list_to_bin
  end

  def to_packet(packet = %ExTds.Packet.Login7{}) do
    header = <<
      0x04, 0x00, 0x00, 0x74,         # TDS Version
      4096 :: little-size(4)-unit(8), # Packet Size
      0x04, 0x00, 0x00, 0x07,         # Client Program Version
      0x00, 0x10, 0x00, 0x00,         # Client PID
      0x00 :: little-size(4)-unit(8), # Connection ID
      0x00,                           # Option flags 1
      0x00,                           # Option flags 2
      0x00,                           # Type flags
      0x00,                           # Option flags 3
      0xE0, 0x01, 0x00, 0x00,         # Time zone
      0x09, 0x04, 0x00, 0x00          # Collation ID
    >>

    {header, body, size} =
      {header, <<>>, 94}
      |> add_variable_length_string("")      # Client hostname
      |> add_variable_length_string(packet.username)      # Username
      |> add_variable_length_binary(encrypt_password(packet.password))      # Password
      |> add_variable_length_string("")      # App name
      |> add_variable_length_string(packet.hostname)      # Server name
      |> add_variable_length_string("")      # Unused
      |> add_variable_length_string("")      # Library name
      |> add_variable_length_string("")      # Language
      |> add_variable_length_string(packet.database)      # Database name
      |> add_fixed_length_field(<<0x00 :: size(48)>>) # Client ID
      |> add_variable_length_string()        # SSPI
      |> add_variable_length_string()        # Attach DB File
      |> add_variable_length_string()        # Change password
      |> add_fixed_length_field(<<0x00 :: size(32)>>) # SSPI Long

    <<size :: little-size(32)>> <> header <> body
  end

  defp add_variable_length_string(state, s), do: add_variable_length_binary(state, Utils.to_ucs2(s))
  defp add_variable_length_string({header, body, offset}) do
    {
      header <> <<0 :: little-size(16), 0 :: little-size(16)>>,
      body,
      offset
    }
  end

  defp add_variable_length_binary({header, body, offset}, s) do
    len = byte_size(s)

    {
      header <> <<offset :: little-size(16), len >>> 1 :: little-size(16)>>,
      body <> s,
      offset + len
    }
  end 


  defp add_fixed_length_field({header, body, offset}, field), do: {header <> field, body, offset}
end
