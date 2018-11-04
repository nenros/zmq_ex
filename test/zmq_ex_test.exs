defmodule ZmqExTest do
  use ExUnit.Case
  doctest ZmqEx

  test "version" do
    assert ZmqEx.version() == "0.0.1"
  end
end
