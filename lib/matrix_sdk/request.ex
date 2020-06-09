defmodule MatrixSDK.Request do
  @moduledoc """
  Provides functions which return a struct containing the data necessary for
  each HTTP request.
  """

  alias MatrixSDK.Auth

  @enforce_keys [:method, :base_url, :path]
  defstruct([:method, :base_url, :path, headers: [], body: %{}])

  @type method :: :head | :get | :delete | :trace | :options | :post | :put | :patch
  @type base_url :: binary
  @type path :: binary
  @type headers :: [{binary, binary}]
  @type body :: any

  @type t :: %__MODULE__{
          method: method,
          base_url: base_url,
          path: path,
          headers: headers,
          body: body
        }

  @doc """
  Returns a `%Request{}` struct used to get the versions of the Matrix specification
  supported by the server.

  ## Examples

      iex> MatrixSDK.Request.spec_versions("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/versions"
      }
  """
  @spec spec_versions(base_url) :: t
  def spec_versions(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/versions"}

  @doc """
  Returns a `%Request{}` struct used to get discovery information about the domain. 

  ## Examples

      iex> MatrixSDK.Request.server_discovery("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/.well-known/matrix/client"
      }
  """
  @spec server_discovery(base_url) :: t
  def server_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/.well-known/matrix/client"}

  @doc """
  Returns a `%Request{}` struct used to get the homeserver's supported login types to authenticate users. 

  ## Examples

      iex> MatrixSDK.Request.login("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/login"
      }
  """
  @spec login(base_url) :: t
  def login(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/login"}

  @doc """
  Returns a `%Request{}` struct used to authenticate the user and issues an access token
  they can use to authorize themself in subsequent requests.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver 
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Auth`.

  Optional:
  - `device_id`: ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a `device_id` if this is not specified.
  - `initial_device_display_name`: a display name to assign to the newly-created device


  ## Examples
      
  Token authentication:
      iex> auth = MatrixSDK.Auth.login_token("token")
      iex> MatrixSDK.Request.login("https://matrix.org", auth)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{token: "token", type: "m.login.token"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/login"
      }

  User and password authentication with optional parameters:

      iex> auth = MatrixSDK.Auth.login_user("maurice_moss", "password")
      iex> opts = %{device_id: "id", initial_device_display_name: "THE INTERNET"}
      iex> MatrixSDK.Request.login("https://matrix.org", auth, opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          identifier: %{type: "m.id.user", user: "maurice_moss"},
          password: "password",
          type: "m.login.password",
          device_id: "id",
          initial_device_display_name: "THE INTERNET"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/login"
      }
  """
  @spec login(base_url, Auth.t(), opts :: map) :: t
  def login(base_url, auth, opts \\ %{}) do
    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/login",
      body: Map.merge(opts, auth)
    }
  end

  @doc """
  Returns a `%Request{}` struct used to invalidate an existing access token, so that it can no longer be used for authorization.

  ## Examples
      iex> MatrixSDK.Request.logout("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout"
      }
  """
  @spec logout(base_url, binary) :: t
  def logout(base_url, token), do: logout(base_url, "/_matrix/client/r0/logout", token)

  defp logout(base_url, path, token),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: path,
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Returns a `%Request{}` struct used to invalidate all existing access tokens, so that they can no longer be used for authorization.

  ## Examples

      iex> MatrixSDK.Request.logout_all("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout/all"
      }
  """
  @spec logout_all(base_url, binary) :: t
  def logout_all(base_url, token), do: logout(base_url, "/_matrix/client/r0/logout/all", token)

  @doc """
  Returns a `%Request{}` struct used to register a guest account on the homeserver. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver 

  Optional: 
  - `initial_device_display_name`: a display name to assign to the newly-created device

  ## Examples

      iex> MatrixSDK.Request.register_guest("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest"
      }   

  Specifiying a display name for the device:    

      iex> opts = %{initial_device_display_name: "THE INTERNET"}
      iex> MatrixSDK.Request.register_guest("https://matrix.org", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{initial_device_display_name: "THE INTERNET"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest"
      }
  """
  @spec register_guest(base_url, map) :: t
  def register_guest(base_url, opts \\ %{}),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register?kind=guest",
      body: opts
    }

  @doc """
  Returns a `%Request{}` struct used to register a user account on the homeserver. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver 
  - `password`: the desired password for the account

  Optional: 
  - `username`: the basis for the localpart of the desired Matrix ID. If omitted, the homeserver will generate a Matrix ID local part.
  - `device_id`: ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a `device_id` if this is not specified.
  - `initial_device_display_name`: a display name to assign to the newly-created device
  - `inhibit_login`: if true, an `access_token` and `device_id` will not be returned from this call, therefore preventing an automatic login

  ## Examples

      iex> MatrixSDK.Request.register_user("https://matrix.org", "password")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{auth: %{type: "m.login.dummy"}, password: "password"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register"
      }

  With optional parameters:    

      iex> opts = %{
      ...>          username: "maurice_moss",
      ...>          device_id: "id",
      ...>          initial_device_display_name: "THE INTERNET",
      ...>          inhibit_login: true
      ...>        }
      iex> MatrixSDK.Request.register_user("https://matrix.org", "password", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          auth: %{type: "m.login.dummy"},
          device_id: "id",
          inhibit_login: true,
          initial_device_display_name: "THE INTERNET",
          password: "password",
          username: "maurice_moss"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register"
      }
  """
  @spec register_user(base_url, binary, map) :: t
  def register_user(base_url, password, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:password, password)
      |> Map.put(:auth, Auth.login_dummy())
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register",
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to check if a username is available and valid for the server.

  ## Examples

       iex> MatrixSDK.Request.username_availability("https://matrix.org", "maurice_moss")
       %MatrixSDK.Request{
         base_url: "https://matrix.org",
         body: %{},
         headers: [],
         method: :get,
         path: "/_matrix/client/r0/register/available?username=maurice_moss"
       }
  """
  @spec username_availability(base_url, binary) :: t
  def username_availability(base_url, username),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/register/available?username=#{username}"
    }

  def change_password(base_url, new_password, auth, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:new_password, new_password)
      |> Map.put(:auth, auth)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/password",
      body: body
    }
  end

  def room_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/publicRooms"}
end
