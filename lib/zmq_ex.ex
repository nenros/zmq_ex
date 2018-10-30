defmodule ZmqEx do
  @moduledoc """
  Documentation for ZmqEx.
  """

  @doc """
  """
  def start do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 5555, opts)
    printer_process = spawn(fn -> printer_loop() end)
    send? = start_connection(socket)
    spawn(fn -> rec_loop(socket, printer_process) end)

    if send? do
      send_loop(socket)
    end
  end

  defp printer_loop do
    receive do
      {:rec_message, value} ->
        IO.puts(value)
      _ ->
        IO.puts("wrong msg")
        printer_loop()
    end
  end

  defp send_loop(socket) do
    reply = IO.gets("Please enter something: ")
    enc_reply = encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket)
  end

  defp rec_loop(socket, pid) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    dmsg = decode(msg)
    send(pid, {:rec_message, dmsg})
    rec_loop(socket, pid)
  end

  defp start_connection(socket) do
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg1)
    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg3)

    ready(socket)
    check_ready(socket)
  end

  defp ready(socket),
    do:
      :gen_tcp.send(
        socket,
        <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", 0, 0, 0, 0>>
      )

  def check_ready(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)

    case msg do
      <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", _data::binary>> ->
        true

      _ ->
        false
    end
  end

  def recv(socket, send?) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    dmsg = decode(msg)
    IO.puts(dmsg)

    if send? == :send do
      reply = IO.gets("Please enter something: ")
      enc_reply = encode(reply)
      IO.puts(enc_reply)
      :gen_tcp.send(socket, enc_reply)
    end

    # :gen_tcp.send(socket, msg)
    recv(socket, send?)
  end

  def encode(msg), do: <<0, byte_size(msg)::size(8), msg::binary>>

  def decode(
        <<4, s::size(8), comm_size, comm::binary-size(comm_size), comm_size_2,
          comm_2::binary-size(comm_size_2), 0, 0, 0, comm_size_3,
          comm_3::binary-size(comm_size_3), comm_size_4, comm_4::binary-size(comm_size_4),
          body::binary>>
      ),
      do: {s, comm, comm_2, comm_3, comm_4, body}

  def decode(<<0, msg_size, msg::binary-size(msg_size)>>), do: msg

  ## test version
  def version do
    0
  end
end
