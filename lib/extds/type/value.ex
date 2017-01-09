defmodule ExTds.Type.Value do
  # https://msdn.microsoft.com/en-us/library/ee780892.aspx

  @year_1900 :calendar.date_to_gregorian_days({1900,1,1})

  def parse(%{type: :string}, tail) do
    <<size :: little-size(16), value :: binary-size(size), tail :: binary>> = tail

    {ExTds.Utils.ucs2_to_utf(value), tail}
  end

  # Variable types with 0 length are nil
  def parse(%{data_type: :variable}, <<0x00, tail :: binary>>), do: {nil, tail}

  # Booleans
  def parse(%{sqltype: :bit, data_type: :fixed}, <<bit, tail :: binary>>), do: {bit != 0x00, tail}
  def parse(%{sqltype: :bit, data_type: :variable}, <<0x01, bit, tail :: binary>>), do: {bit != 0x00, tail}
  
  # Integers
  def parse(%{type: :integer, data_type: :fixed, size: size}, <<tail :: binary>>) do
    <<value :: little-signed-size(size)-unit(8), tail :: binary>> = tail
    {value, tail}
  end
  def parse(%{type: :integer, data_type: :variable}, <<size, value :: little-signed-size(size)-unit(8), tail :: binary>>), do: {value, tail}

  def parse(%{sqltype: :datetime}, <<days :: little-signed-32, seconds_300 :: little-unsigned-32, tail :: binary>>) do
    date =
      @year_1900 + days
      |> :calendar.gregorian_days_to_date

    seconds = div(seconds_300, 300)

    {_, {h, m, s}} = 
      seconds
      |> :calendar.seconds_to_daystime

    sub_seconds = (seconds_300 / 300) - seconds

    micro_seconds = (sub_seconds * 1000000 + 0.5) |> trunc

    {{date, {h, m, s, micro_seconds}}, tail}
  end
end
