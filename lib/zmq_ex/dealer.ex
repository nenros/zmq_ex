defmodule ZmqEx.Dealer do
  require Logger
  use GenServer

  def create_socket() do
    Logger.debug("Creating DEALER socket.")
    GenServer.start_link(__MODULE__, [])
  end

  def bind(pid, port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
  end

  def connect(pid, port) do
    connect(pid, port, 'localhost')
  end

  def connect(pid, port, host) do
    Logger.debug("Connectint to #{host} on #{port} ")
    opts = [:binary, active: false]

    case :gen_tcp.connect(host, port, opts) do
      {:ok, socket} ->
        send? = start_connection(socket)
        spawn(fn -> rec_loop(socket, pid) end)
        GenServer.cast(pid, {:add_bind, socket})

      {:error, error} ->
        Logger.error("Error during connecting to #{host}:#{port}, error:#{error}")
        {:error, error}
    end
  end

  def send_message(pid, message) do
  end

  ## client api

  ## genserver api

  @impl true
  def init(_data) do
    data = %{
      binds: [],
      listeners: [],
      messages_received: [],
      massages_sent: []
    }

    {:ok, data}
  end

  @impl true
  def handle_call(msg, _from, state) do
  end

  @impl true
  def handle_cast({:add_bind, socket}, state) do
    Logger.debug("Adding new bind")
    {:noreply, %{state | binds: [socket] ++ state[:binds]}}
  end

  @impl true
  def handle_cast({:new_message, msg}, state) do
    Logger.debug("Cast: #{IO.inspect(msg)} ")
    {:noreply, %{state | messages_received: [state[:messages_received] | msg]}}
  end

  @impl true
  def handle_cast({:remove_bind, socket}, state) do
    Logger.debug("Removing bind ")
    {:noreply, %{state | binds: Enum.filter(state[:binds], fn s -> s !== socket end)}}
  end

  defp send_loop(socket) do
    reply = IO.gets("Please enter something: ")
    enc_reply = encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket)
  end

  defp rec_loop(socket, pid) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, msg} ->
        dmsg = decode(msg)
        Logger.debug("Got message: #{dmsg}")
        GenServer.cast(pid, {:new_message, dmsg})
        rec_loop(socket, pid)

      {:error, :closed} ->
        Logger.info("Connection closed")
        GenServer.cast(pid, {:remove_bind, socket})
    end
  end

  defp start_connection(socket) do
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    IO.inspect(String.codepoints(msg1))
    :gen_tcp.send(socket, msg1)
    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    IO.inspect(String.codepoints(msg2))
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    IO.inspect(String.codepoints(msg3))
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
    IO.inspect(msg)

    case msg do
      <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", _data::binary>> ->
        true

      _ ->
        false
    end
  end

  def recv(socket, send?) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    IO.inspect(msg)
    dmsg = decode(msg)
    IO.inspect(dmsg)

    if send? == :send do
      reply = IO.gets("Please enter something: ")
      enc_reply = encode(reply)
      IO.inspect(enc_reply)
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
end
