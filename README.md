# ZmqEx
[![CircleCI](https://circleci.com/gh/half-t/zmq_ex.svg?style=svg)](https://circleci.com/gh/half-t/zmq_ex)
[![Coverage Status](https://coveralls.io/repos/github/half-t/zmq_ex/badge.svg?branch=master)](https://coveralls.io/github/half-t/zmq_ex?branch=master)

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zmq_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zmq_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/zmq_ex](https://hexdocs.pm/zmq_ex).

## Additional tools

    * Credo: `mix credo --strict` - a static code analysis tool for Elixir
    * Dialyzer: `mix dialyzer` - a type checker
    * Formatter: `mix format --check-formatted` - build in elixir formatter

## python enV

```
virtualenv -p python3 ./py
. ./py/bin/activate
pip install pyzmq
python ./python_server.py
```

