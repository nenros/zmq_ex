defmodule ZmqEx do
  @moduledoc """
  Documentation for ZmqEx.
  """

  @doc """
  """
  def start do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 5555, opts)
    start_recv socket
  end

  def start_recv(socket) do
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg1)
    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg3)

    IO.inspect msg1
    IO.inspect msg2
    IO.inspect msg3

    ready(socket)
    recv(socket)
  end

  def ready(socket) do
    :gen_tcp.send(socket, <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", 0, 0, 0 ,0>>)

  end

  def recv(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    dmsg = decode msg
    IO.inspect msg
    IO.inspect dmsg
    # :gen_tcp.send(socket, msg)
    recv(socket)
  end

  def decode(<<4, s :: size(8),
                comm_size, comm :: binary - size(comm_size),
                comm_size_2, comm_2 :: binary - size(comm_size_2),
                0, 0, 0, x :: size(8),
                body :: binary>>) do
    {s, comm, comm_2, x, body}
  end
end
