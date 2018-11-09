defmodule ZmqEx.Common do
  require Logger


  @moduledoc """
  Should be removed in next taska
  """

  def start_connection(socket) do
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg1)
    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg3)

    ready(socket)
    check_ready(socket)
  end

  def rec_loop(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    Logger.debug(fn -> "Raw message: #{inspect(msg)}" end)
    dmsg = ZmqEx.Message.decode(msg)
    Logger.debug(fn -> "Decoded message: #{inspect(dmsg)}" end)
    rec_loop(socket)
  end

  def send_loop(socket) do
    reply = IO.gets("Please enter something: ")
    enc_reply = ZmqEx.Message.encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket)
  end

  def ready(socket),
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
end
