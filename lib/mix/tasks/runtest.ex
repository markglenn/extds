defmodule Mix.Tasks.ExTds.Runtest do
  use Mix.Task

  def run(_) do
    ExTds.Connection.connect
  end
end
