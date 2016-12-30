defmodule ExTds.Packet.Login do
  defstruct [:hostname, :username, :password]
  use Bitwise
  import ExTds.Utils, only: [to_ucs2: 1] 

  def encrypt_password(password) do
    password
    |> to_ucs2
    |> :binary.bin_to_list
    |> Enum.map(fn b ->
      # Swap the top and bottom nibbles 
      <<x::size(4), y::size(4)>> = <<b>>
      <<c>> = <<y::size(4), x::size(4)>>

      Bitwise.bxor(c, 0xA5)
    end)
    |> :binary.list_to_bin
  end
end
