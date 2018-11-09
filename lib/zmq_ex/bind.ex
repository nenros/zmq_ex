defmodule ZmqEx.Bind do
  require Logger

  def create(port) do
    opts = [:binary, active: false]

    {:ok, listen_socket} = :gen_tcp.listen(port, opts)
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    :gen_tcp.send(socket, "connected!")

    ZmqEx.Common.start_connection(socket)
    spawn(fn -> ZmqEx.Common.rec_loop(socket) end)

    ZmqEx.Common.send_loop(socket)
  end

end
