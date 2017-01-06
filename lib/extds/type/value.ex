defmodule ExTds.Type.Value do
  @year_1900 :calendar.date_to_gregorian_days({1900,1,1})

  def parse(tail, %{sqltype: :bigchar}) do
    <<size :: little-size(16), value :: binary-size(size), tail :: binary>> = tail

    {ExTds.Utils.ucs2_to_utf(value), tail}
  end
  def parse(tail, %{sqltype: :nvarchar}) do
    <<size :: little-size(16), value :: binary-size(size), tail :: binary>> = tail

    {ExTds.Utils.ucs2_to_utf(value), tail}
  end

  # Booleans
  def parse(<<bit, tail :: binary>>, %{sqltype: :bit, data_type: :fixed}), do: {bit == 0x01, tail}
  def parse(<<0x01, bit, tail :: binary>>, %{sqltype: :bit, data_type: :variable}), do: {bit != 0x00, tail}
  def parse(<<0x00, tail :: binary>>, %{sqltype: :bit, data_type: :variable}), do: {nil, tail}
  
  # Integers
  def parse(<<value :: little-signed-size(32), tail :: binary>>, %{sqltype: :int, data_type: :fixed}), do: {value, tail}
  def parse(<<value, tail :: binary>>, %{sqltype: :tinyint, data_type: :fixed}), do: {value, tail}


  def parse(<<size, value :: little-signed-size(size)-unit(8), tail :: binary>>, %{type: :integer, data_type: :variable}), do: {value, tail}

  def parse(<<days :: little-signed-32, seconds_300 :: little-unsigned-32, tail :: binary>>, %{sqltype: :datetime}) do
    year_1900 = 
      {1900,1,1}
      |> :calendar.date_to_gregorian_days

    date =
      year_1900 + days
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
