defmodule ZmqEx.Socket do
  @callback create_socket(pid) :: {:ok, term} | {:error, String.t}
  @callback extensions() :: [String.t]
end
