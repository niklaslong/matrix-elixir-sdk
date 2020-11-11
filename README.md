# Matrix Elixir SDK

[![GitHub Workflow
Status](https://github.com/niklaslong/matrix-elixir-sdk/workflows/Elixir%20CI/badge.svg)](https://github.com/niklaslong/matrix-elixir-sdk/actions?query=workflow%3A%22Elixir+CI%22+branch%3Amaster)
[![Hex.pm](https://img.shields.io/hexpm/v/matrix_sdk)](https://hex.pm/packages/matrix_sdk)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

A [Matrix](https://matrix.org/) SDK for Elixir. It is currently in active (and
early) development. The docs can be found at
[https://hexdocs.pm/matrix_sdk](https://hexdocs.pm/matrix_sdk). 

The library currently provides a simple wrapper around the main endpoints of the
[Matrix client-server API](https://matrix.org/docs/spec/client_server/r0.6.1).
There are still many endpoints to be implemented; if you feel like
contributing, please don't hesitate to open an issue or a PR (all skill levels
welcome)!

## Roadmap

In future, the SDK plans to include:
- an encryption library (currently in development):
  [olm-elixir](https://github.com/niklaslong/olm-elixir).
- further abstractions around the `API` library to handle state.
- a wrapper for the Server-Server API
- & more tbd. 

## Installation

The package can be installed by adding `matrix_sdk` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:matrix_sdk, "~> 0.2.0"}
  ]
end
```

## Basic Usage

To make a request to a Matrix homeserver, you need to create a `Request`
struct. This struct provides all the data to make a request to a specific
endpoint of the client-server API. It is then executed with `do_request/1`. 


```elixir
alias MatrixSDK.API
alias MatrixSDK.API.Request
 
"https://matrix.org"
|> Request.spec_versions()
|> API.do_request()
```

This example will retreive the versions of the specification supported by the `matrix.org` homeserver. 

The [examples](examples/) also demonstrate usage and can be executed with e.g.: `mix run examples/guest_login.exs`
