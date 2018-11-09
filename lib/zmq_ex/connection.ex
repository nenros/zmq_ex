defmodule ZmqEx.Connection do


  def create(port) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)

    :gen_tcp.send(socket, "connected!")

    ZmqEx.Common.start_connection(socket)
    spawn(fn -> ZmqEx.Common.rec_loop(socket) end)

    ZmqEx.Common.send_loop(socket)
  end



end
