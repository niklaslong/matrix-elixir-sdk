defmodule MatrixSDK.Request do
  @enforce_keys [:method, :base_url, :path]
  defstruct([:method, :base_url, :path, headers: [], body: %{}])

  @type t :: %__MODULE__{
          method: atom,
          base_url: String.t(),
          path: String.t(),
          headers: [{String.t(), String.t()}],
          body: any
        }

  def spec_versions(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/versions"}

  def server_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/.well-known/matrix/client"}

  def login(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/login"}

  def login(base_url, username, password),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/login",
      body: %{
        type: "m.login.password",
        user: username,
        password: password
      }
    }

  def logout(base_url, token),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/logout",
      headers: [{"Authorization", "Bearer " <> token}]
    }

  def register_user(base_url),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register?kind=guest"
    }

  def register_user(base_url, username, password),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register",
      body: %{
        auth: %{type: "m.login.dummy"},
        username: username,
        password: password
      }
    }

  def room_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/publicRooms"}
end
