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
    IO.inspect msg
    dmsg = decode msg
    IO.inspect dmsg
    # :gen_tcp.send(socket, msg)
    recv(socket)
  end

  def decode(<<4, s :: size(8),
                comm_size, comm :: binary - size(comm_size),
                comm_size_2, comm_2 :: binary - size(comm_size_2), 0, 0, 0,
                comm_size_3, comm_3 :: binary - size(comm_size_3),
                comm_size_4, comm_4 :: binary - size(comm_size_4),
                body :: binary>>), do:
    {s, comm, comm_2, comm_3, comm_4, body}
  def decode(<<0, msg_size, msg :: binary - size(msg_size)>>), do: msg
end
