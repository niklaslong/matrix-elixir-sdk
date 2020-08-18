# Matrix Elixir SDK 

A [Matrix](https://matrix.org/) SDK for Elixir. It is currently in active (and early) development and hasn't yet been released to Hex. 

The first release will provide a simple wrapper around the [Matrix client-server API](https://matrix.org/docs/spec/client_server/r0.6.1). 

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

## Basic Usage

Here is an example to login with username and password:

```elixir
iex(1)> url = "https://matrix.org"
"https://matrix.org"
iex(2)> auth = MatrixSDK.Client.Auth.login_user("mickey", "supersecret")
%{
  identifier: %{type: "m.id.user", user: "mickey"},
  password: "supersecret",
  type: "m.login.password"
}
iex(3)> {:ok, %{body: %{"access_token" => token}}} = MatrixSDK.Client.login(url, auth)
...
iex(4)> MatrixSDK.Client.joined_rooms(url, token)
...
iex(5)> MatrixSDK.Client.logout(url, token)
...
```

Here is an example with a guest account. When initially joining the room it will
ask you to fill out a consent form in the browser. Once this is done try joining
the room again.

We will keep the room address open until it is deemed unnecessary or being abused.

```elixir
iex(1)> url = "https://matrix.org"
"https://matrix.org"
iex(2)> {:ok, %{body: %{"access_token" => token}}} = MatrixSDK.Client.register_guest(url)
...
iex(3)> room_address = "#elixirsdktest:matrix.org"
"#elixirsdktest:matrix.org"
iex(4)> {:ok, %{body: %{"consent_uri" => consent_uri}}} = MatrixSDK.Client.join_room(url, token, room_address)
# Open this link with your browser
iex(5)> MatrixSDK.Client.join_room(url, token, room_address)
...
```
