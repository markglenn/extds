defmodule ExTds.Type do
  alias __MODULE__
  @year_1900 :calendar.date_to_gregorian_days({1900,1,1})

  # Fixed length types
  def parse(<<0x1F, tail :: binary>>), do: {%{type: :nil,       sqltype: :null},          tail}
  def parse(<<0x30, tail :: binary>>), do: {%{type: :integer,   sqltype: :tinyint},       tail}
  def parse(<<0x32, tail :: binary>>), do: {%{type: :boolean,   sqltype: :bit},           tail}
  def parse(<<0x34, tail :: binary>>), do: {%{type: :integer,   sqltype: :smallint},      tail}
  def parse(<<0x38, tail :: binary>>), do: {%{type: :integer,   sqltype: :int},           tail}
  def parse(<<0x3A, tail :: binary>>), do: {%{type: :datetime,  sqltype: :smalldatetime}, tail}
  def parse(<<0x3B, tail :: binary>>), do: {%{type: :float,     sqltype: :real},          tail}
  def parse(<<0x3C, tail :: binary>>), do: {%{type: :decimal,   sqltype: :money},         tail}
  def parse(<<0x3D, tail :: binary>>), do: {%{type: :datetime,  sqltype: :datetime},      tail}
  def parse(<<0x3E, tail :: binary>>), do: {%{type: :float,     sqltype: :float},         tail}
  def parse(<<0x7A, tail :: binary>>), do: {%{type: :decimal,   sqltype: :smallmoney},    tail}
  def parse(<<0x7F, tail :: binary>>), do: {%{type: :integer,   sqltype: :bigint},        tail}

  def parse(<<0x24, _size, tail :: binary>>), do: {%{type: :unique_identifier, sqltype: :uuid}, tail}

  def parse(<<0x26, size, tail :: binary>>) do
    sqltype = case size do
      1 -> :tinyintn
      2 -> :smallintn
      4 -> :intn
      8 -> :bigintn
    end

    type = %{
      type: :integer,
      size: size,
      sqltype: sqltype
    }

    {type, tail}
  end

  def parse(<<0x68, _size, tail :: binary>>), do: {%{type: :boolean, sqltype: :bitn}, tail}
  def parse(<<0x6A, size, precision, scale, tail :: binary>>) do
    {
      %{type: :decimal, precision: precision, scale: scale, sqltype: :decimal},
      tail
    }
  end

  def parse(<<0x6C, size, precision, scale, tail :: binary>>) do
    {
      %{type: :decimal, precision: precision, scale: scale, sqltype: :numeric},
      tail
    }
  end

  def parse(<<0x6D, 4, tail :: binary>>), do: {%{type: :float,  sqltype: :float}, tail}
  def parse(<<0x6D, 8, tail :: binary>>), do: {%{type: :double, sqltype: :double}, tail}

  def parse(<<0x6E, 4, tail :: binary>>), do: {%{type: :money, sqltype: :smallmoney}, tail}
  def parse(<<0x6E, 8, tail :: binary>>), do: {%{type: :money, sqltype: :money}, tail}

  def parse(<<0xAF, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>) do
    {
      %{type: :string, sqltype: :char, size: type_size},
      tail
    }
  end

  def parse(<<0xE7, type_size :: little-size(16), collation :: binary-size(5), tail :: binary>>) do
    type = %{
      type: :string,
      sqltype: :nvarchar,
      size: type_size,
      collation: parse_collation(collation)
    }

    {type, tail}
  end

  defp parse_collation(<<code_page :: little-size(16), flags :: little-size(16), charset>>) do
    %{ code_page: code_page, flags: flags, charset: charset }
  end

  def parse_value(tail, %{sqltype: :char}), do: parse_value(tail, %{sqltype: :nvarchar})
  def parse_value(tail, %{sqltype: :nvarchar}) do
    <<size :: little-size(16), value :: binary-size(size), tail :: binary>> = tail

    {ExTds.Utils.ucs2_to_utf(value), tail}
  end

  # Booleans
  def parse_value(<<bit, tail :: binary>>, %{sqltype: :bit}), do: {bit == 0x01, tail}
  def parse_value(<<0x01, bit, tail :: binary>>, %{sqltype: :bitn}), do: {bit != 0x00, tail}
  def parse_value(<<0x00, tail :: binary>>, %{sqltype: :bitn}), do: {nil, tail}
  
  # Integers
  def parse_value(<<value :: little-signed-size(32), tail :: binary>>, %{sqltype: :int}), do: {value, tail}
  def parse_value(<<value, tail :: binary>>, %{sqltype: :tinyint}), do: {value, tail}
  def parse_value(<<size, value :: little-signed-size(size)-unit(8), tail :: binary>>, %{sqltype: :tinyintn, size: size}), do: {value, tail}
  def parse_value(<<size, value :: little-signed-size(size)-unit(8), tail :: binary>>, %{sqltype: :smallintn, size: size}), do: {value, tail}
  def parse_value(<<size, value :: little-signed-size(size)-unit(8), tail :: binary>>, %{sqltype: :intn, size: size}), do: {value, tail}
  def parse_value(<<size, value :: little-signed-size(size)-unit(8), tail :: binary>>, %{sqltype: :bigintn, size: size}), do: {value, tail}

  def parse_value(<<days :: little-signed-32, seconds_300 :: little-unsigned-32, tail :: binary>>, %{sqltype: :datetime}) do
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
