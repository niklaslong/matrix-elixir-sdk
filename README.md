# MatrixSDK

This will hopefully become the Matrix SDK for Elixir. It is currently in active (and early) development and hasn't yet been released to Hex. 

The first release will provide a simple wrapper around the Matrix client-server API. 

## Starting a local homeserver

If you have a synapse server installed it can be started as follows:

```
cd synapse
source env/bin/activate
synctl start

synctl stop 
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `matrix_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:matrix_sdk, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/matrix_sdk](https://hexdocs.pm/matrix_sdk).
