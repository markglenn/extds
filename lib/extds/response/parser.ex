defmodule ExTds.Response.Parser do
  @callback parse(binary) :: any
end
