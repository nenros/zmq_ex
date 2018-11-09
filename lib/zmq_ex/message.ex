defmodule ZmqEx.Message do
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
