# Matrix Elixir SDK 

A [Matrix](https://matrix.org/) SDK for Elixir. It is currently in active (and early) development. The first (unstable) version has been released to hex. The docs can be found at [https://hexdocs.pm/matrix_sdk](https://hexdocs.pm/matrix_sdk). 

The first release provides a simple wrapper around the main endpoints of the [Matrix client-server API](https://matrix.org/docs/spec/client_server/r0.6.1). There are still many endpoints to be implemented; if you feel like contributing, please don't hesitate to open an issue or a PR (all skill levels welcome)!

Likewise, if you want to start a project using the SDK, [let me know](mailto:niklaslong@protonmail.ch)!

## Roadmap

In future, the SDK plans to include:
- an encryption library (currently in development): [olm-ex](https://github.com/niklaslong/olm-ex).
- further abstractions around the `Client` library to handle state.
- a wrapper for the Server-Server API
- & more tbd. 

## Installation

The package can be installed
by adding `matrix_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:matrix_sdk, "~> 0.1.0"}
  ]
end
```

## Basic Usage

Guest account registration. When initially joining the room it will
ask you to fill out a consent form in the browser. Once this is done try joining
the room again.

```elixir
# Set the URL for the homeserver, this is the first argument of every function in the Client. 
iex(1)> url = "https://matrix.org"
# Set the room, this is used for the join_room/3 call.
iex(2)> room = "#elixirsdktest:matrix.org"
# ...
iex(3)> {:ok, %{body: %{"access_token" => token}}} = MatrixSDK.Client.register_guest(url)
# ...
iex(4)> {:ok, %{body: %{"consent_uri" => consent_uri}}} = MatrixSDK.Client.join_room(url, token, room)
# Open the link in the browser and accept the terms. 
iex(5)> MatrixSDK.Client.join_room(url, token, room_address)
# ...
```

Username and password login with an existing account:

```elixir
iex(1)> url = "https://matrix.org"
# ...
iex(2)> auth = MatrixSDK.Client.Auth.login_user("username", "supersecretpassword")
%{
  identifier: %{type: "m.id.user", user: "username"},
  password: "supersecretpassword",
  type: "m.login.password"
}
iex(3)> {:ok, %{body: %{"access_token" => token}}} = MatrixSDK.Client.login(url, auth)
# ...
iex(4)> MatrixSDK.Client.joined_rooms(url, token)
# Returns a list of the rooms joined with that account.
iex(5)> MatrixSDK.Client.logout(url, token)
# Invalidates the token and logs the user out.
```
