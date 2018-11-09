defmodule ZmqEx.Socket.Dealer do
  require Logger
  use GenServer
  # use ZmqEx.Socket

  def create_socket() do
    Logger.debug("Creating DEALER socket.")
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_data) do
    data = %{
      socket_type: "DEALER",
      ports: [],
      messages_received: [],
      massages_sent: []
    }

    {:ok, data}
  end



end
