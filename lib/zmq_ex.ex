defmodule ZmqEx do
  @moduledoc """
  Documentation for ZmqEx.
  """

  def version do
    {:ok, vsn} = :application.get_key(:zmq_ex, :vsn)
    List.to_string(vsn)
  end

  @doc """
  """

  require Logger

  def start_server do
    opts = [:binary, active: false]

    {:ok, listen_socket} = :gen_tcp.listen(5555, opts)
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    :gen_tcp.send(socket, "connected!")

    start_connection(socket)
    spawn(fn -> rec_loop(socket) end)

    send_loop(socket)
  end

  def start_client do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 5555, opts)

    :gen_tcp.send(socket, "connected!")

    start_connection(socket)
    spawn(fn -> rec_loop(socket) end)

    send_loop(socket)
  end

  defp send_loop(socket) do
    reply = IO.gets("Please enter something: ")
    enc_reply = encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket)
  end

  defp rec_loop(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    Logger.debug(fn -> "Raw message: #{inspect(msg)}" end)
    dmsg = decode(msg)
    Logger.debug(fn -> "Decoded message: #{inspect(dmsg)}" end)
    rec_loop(socket)
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

  defp check_ready(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)

    case msg do
      <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", _data::binary>> ->
        true

      _ ->
        false
    end
  end

  defp encode(msg), do: <<0, byte_size(msg)::size(8), msg::binary>>

  defp decode(
         <<4, s::size(8), comm_size, comm::binary-size(comm_size), comm_size_2,
           comm_2::binary-size(comm_size_2), 0, 0, 0, comm_size_3,
           comm_3::binary-size(comm_size_3), comm_size_4, comm_4::binary-size(comm_size_4),
           body::binary>>
       ),
       do: {s, comm, comm_2, comm_3, comm_4, body}

  defp decode(<<0, msg_size, msg::binary-size(msg_size)>>), do: msg
end
