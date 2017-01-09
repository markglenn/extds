defmodule ExTds.Utils do

  def to_ucs2(nil), do: <<>>
  def to_ucs2(s) do
    :unicode.characters_to_binary(s, :utf8, {:utf16, :little})
  end

  def ucs2_to_utf(s) do
    :unicode.characters_to_binary(s, {:utf16, :little})
  end
end
