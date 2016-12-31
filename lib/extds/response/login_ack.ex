defmodule ExTds.Response.LoginAck do
  @behaviour ExTds.Response.Parser

  alias __MODULE__

  defstruct [:interface, :tds_version, :program_name, :major_version, :minor_version, :build_num_high, :build_num_low]

  def parse(response) do
    <<
    interface,
    tds_version :: size(32),
    pn_size,
    program_name :: binary-size(pn_size)-unit(16),
    major_version,
    minor_version,
    build_num_high,
    build_num_low,
    _tail :: binary
    >> = response

    %LoginAck{
      interface: interface,
      tds_version: tds_version,
      program_name: ExTds.Utils.ucs2_to_utf(program_name),
      major_version: major_version,
      minor_version: minor_version,
      build_num_high: build_num_high,
      build_num_low: build_num_low
    }
  end
end
