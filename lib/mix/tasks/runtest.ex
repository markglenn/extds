defmodule Mix.Tasks.ExTds.Runtest do
  use Mix.Task
  alias ExTds.Connection

  def run(_) do
    with {:ok, conn} <- Connection.connect,
         {:ok, conn} <- Connection.begin_transaction(conn),
         {:ok, results, conn} <- Connection.execute_raw(conn, "SELECT * FROM sys.tables"),
         IO.inspect(results),
         {:ok, conn} <- Connection.rollback_transaction(conn),
     do: Connection.disconnect(conn)
  end
end
