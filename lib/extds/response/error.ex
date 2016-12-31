defmodule ExTds.Response.Error do
  alias ExTds.Response.Error
  require IEx

  defstruct [:error_number, :state, :class, :message, :server_name, :proc_name, :line_number]

  def parse(response) do
    <<
      error_number :: little-size(32),
      state,
      class,
      message_size :: little-size(16),
      message :: binary-size(message_size)-unit(16),
      sn_size,
      server_name :: binary-size(sn_size)-unit(16),
      pn_size,
      proc_name :: binary-size(pn_size)-unit(16),
      line_number :: little-size(32),
      _tail :: binary
    >> = response

    %Error{
      error_number: error_number,
      state: state,
      class: class,
      message: ExTds.Utils.ucs2_to_utf(message),
      server_name: ExTds.Utils.ucs2_to_utf(server_name),
      proc_name: ExTds.Utils.ucs2_to_utf(proc_name),
      line_number: line_number
    }
  end
end
