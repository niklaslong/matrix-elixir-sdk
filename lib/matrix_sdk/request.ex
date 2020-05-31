defmodule MatrixSDK.Request do
  @enforce_keys [:method, :path]
  defstruct([:method, :path, headers: [], body: %{}])

  def spec_versions(),
    do: %__MODULE__{method: :get, path: "/_matrix/client/versions"}

  def server_discovery(), do: %__MODULE__{method: :get, path: "/.well-known/matrix/client"}

  def login(), do: %__MODULE__{method: :get, path: "/_matrix/client/r0/login"}

  def login(username, password),
    do: %__MODULE__{
      method: :post,
      path: "/_matrix/client/r0/login",
      body: %{
        type: "m.login.password",
        user: username,
        password: password
      }
    }

  def logout(token),
    do: %__MODULE__{
      method: :post,
      path: "/_matrix/client/r0/logout",
      headers: [{"Authorization", "Bearer " <> token}]
    }

  def register_user(),
    do: %__MODULE__{method: :post, path: "/_matrix/client/r0/register?kind=guest"}

  def register_user(username, password),
    do: %__MODULE__{
      method: :post,
      path: "/_matrix/client/r0/register",
      body: %{
        auth: %{type: "m.login.dummy"},
        username: username,
        password: password
      }
    }

  def room_discovery(), do: %__MODULE__{method: :get, path: "/_matrix/client/r0/publicRooms"}
end
