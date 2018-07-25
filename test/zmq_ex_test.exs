defmodule ZmqExTest do
  use ExUnit.Case
  doctest ZmqEx

  test "greets the world" do
    assert ZmqEx.hello() == :world
  end
end
