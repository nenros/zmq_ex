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

  @spec create_socket(:dealer | atom()) :: pid()
  def create_socket(:dealer) do
    {:ok, pid} = ZmqEx.Socket.Dealer.
  end

  @spec add_bind(pid(), integer()) :: pid()
  def add_bind(pid, port) do
    {:ok, bind} = ZmqEx.Bind.create(port)
    GenServer.cast(pid, {:add_bind, bind})
    pid
  end

  def connect_to(pid, address) do
    {:ok, connection} = ZmqEx.Connection.create(address)
    GenServer.cast(pid, {:add_connection, connection})
  end


end
