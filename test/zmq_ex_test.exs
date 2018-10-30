defmodule ZmqExTest do
  use ExUnit.Case
  doctest ZmqEx

  test "version" do
    assert ZmqEx.version() == 0
  end
end
