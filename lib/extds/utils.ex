defmodule ExTds.Utils do

  def to_ucs2(nil), do: <<>>
  def to_ucs2(s) do
    :unicode.characters_to_binary(s, :utf8, {:utf16, :little})
  end

  def ucs2_to_utf(s) do
    :unicode.characters_to_binary(s, {:utf16, :little})
  end

  def trans_id(nil), do: <<0x00 :: little-size(8)-unit(8)>>
  def trans_id(<<_ :: little-size(64)>> = trans), do: trans
end
