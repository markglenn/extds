defmodule ExTds.Utils do
  def to_ucs2(s) do
    s
    |> to_char_list
    |> Enum.map_join(&(<<&1::little-size(16)>>))
  end

  def ucs2_to_utf(s) do
    s
    |> to_char_list
    |> Enum.take_every(2)
    |> Enum.reject(&(&1 == 0))
    |> to_string
  end
end
