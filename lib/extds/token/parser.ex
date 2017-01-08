defmodule ExTds.Token.Parser do
  @callback parse(binary) :: {any, binary}
end
