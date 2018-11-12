defmodule ZmqEx do
  use GenServer

  @moduledoc """
  Documentation for ZmqEx.
  """

  @socket_opts [:binary, active: true]

  def version do
    {:ok, vsn} = :application.get_key(:zmq_ex, :vsn)
    List.to_string(vsn)
  end

  require Logger

  @doc """
  Start server or client on given port.
  Returns pid of socket process.

  """
  @spec start_link(type :: :server | :client, port :: integer) :: pid
  def start_link(type, port) do
    Logger.debug(fn -> "Starting #{type} on port:#{port}" end)
    {:ok, pid} = GenServer.start_link(__MODULE__, [type, port])

    {:ok, pid}
  end

  @impl true
  def init([type, port]) do
    {:ok, socket} =
      case type do
        :server -> start_server(port)
        :client -> start_client(port)
        _ -> {:error, :wrong_type}
      end

    Logger.debug(fn -> "Created socket on port:#{port}" end)
    send(self(), :setup_connection)

    {:ok,
     %{
       connected: false,
       type: type,
       port: port,
       socket: socket
     }}
  end

  @impl true
  def handle_info(:setup_connection, state = %{port: port}) do
    Logger.debug(fn -> "Starting connection on port:#{port}" end)
    # start_connection(socket)
    # spawn(fn -> rec_loop(socket, self()) end)

    # send_loop(socket, self())
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, state) do
    Logger.debug(data)
    :gen_tcp.send(socket, data)
    {:noreply, state}
  end

  defp start_server(port) do
    {:ok, listen_socket} = :gen_tcp.listen(port, @socket_opts)
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    :gen_tcp.send(socket, "connected!")
    {:ok, socket}
  end

  defp start_client(port) do
    {:ok, socket} = :gen_tcp.connect('localhost', port, @socket_opts)
    :gen_tcp.send(socket, "connected!")
    {:ok, socket}
  end

  defp send_loop(socket, pid) do
    reply = IO.gets("Please enter something: ")
    enc_reply = encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket, pid)
  end

  defp rec_loop(socket, pid) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    Logger.debug(fn -> "Raw message: #{inspect(msg)}" end)
    dmsg = decode(msg)
    Logger.debug(fn -> "Decoded message: #{inspect(dmsg)}" end)
    rec_loop(socket, pid)
  end

  defp start_connection(socket) do
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    Logger.debug("sending first message")
    :gen_tcp.send(socket, msg1)
    IO.inspect(socket)

    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    Logger.debug("sending second message")
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    Logger.debug("sending third message")
    :gen_tcp.send(socket, msg3)

    ready(socket)
    check_ready(socket)
    :inet.setopts(socket, active: :once)
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
