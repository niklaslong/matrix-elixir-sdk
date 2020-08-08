defmodule MatrixSDK.Request do
  @moduledoc """
  Provides functions which return a struct containing the data necessary for
  each HTTP request.
  """

  alias MatrixSDK.{Auth, RoomEvent, StateEvent}

  @enforce_keys [:method, :base_url, :path]
  defstruct([:method, :base_url, :path, query_params: %{}, headers: [], body: %{}])

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
  Returns a `%Request{}` struct used to get information about the server's supported feature set and other relevant capabilities.

  ## Examples

      iex> token = "token"
      iex> MatrixSDK.Request.server_capabilities("https://matrix.org", token)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/capabilities"
      }
  """
  @spec server_capabilities(base_url, binary) :: t
  def server_capabilities(base_url, token),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/capabilities",
      headers: [{"Authorization", "Bearer " <> token}]
    }

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
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Auth`

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

      iex> auth = Auth.login_dummy()
      iex> MatrixSDK.Request.register_user("https://matrix.org", "password", auth)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{auth: %{type: "m.login.dummy"}, password: "password"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register"
      }

  With optional parameters:    

      iex> auth = Auth.login_dummy()
      iex> opts = %{
      ...>          username: "maurice_moss",
      ...>          device_id: "id",
      ...>          initial_device_display_name: "THE INTERNET",
      ...>          inhibit_login: true
      ...>        }
      iex> MatrixSDK.Request.register_user("https://matrix.org", "password", auth, opts)
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
  @spec register_user(base_url, binary, Auth.t(), map) :: t
  def register_user(base_url, password, auth, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:password, password)
      |> Map.put(:auth, auth)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register",
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to check the given email address is not already associated with an account on the homeserver. This should be used to get a token to register an email as part of the initial user registration.

  ## Examples

      iex> MatrixSDK.Request.registration_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", email: "maurice@moss.yay", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/email/requestToken"
      }

  With optional parameters:

      iex> opts = %{next_link: "nextlink.url"}
      iex> MatrixSDK.Request.registration_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1, opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "secret",
          email: "maurice@moss.yay",
          send_attempt: 1, 
          next_link: "nextlink.url"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/email/requestToken"
      }
  """
  @spec registration_email_token(base_url, binary, binary, pos_integer, map) :: t
  def registration_email_token(base_url, client_secret, email, send_attempt, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:email, email)
      |> Map.put(:send_attempt, send_attempt)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register/email/requestToken",
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to check the given address phone is not already associated with an account on the homeserver. This should be used to get a token to register a phone number as part of the initial user registration.

  ## Examples

      iex> MatrixSDK.Request.registration_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "secret", 
          country: "GB", 
          phone_number: "07700900001", 
          send_attempt: 1
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/msisdn/requestToken"
      }

  With optional parameters:

      iex> opts = %{next_link: "nextlink.url"}
      iex> MatrixSDK.Request.registration_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1, opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "secret",
          country: "GB", 
          phone_number: "07700900001",
          send_attempt: 1, 
          next_link: "nextlink.url"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/msisdn/requestToken"
      }
  """
  @spec registration_msisdn_token(base_url, binary, binary, binary, pos_integer, map) :: t
  def registration_msisdn_token(
        base_url,
        client_secret,
        country,
        phone,
        send_attempt,
        opts \\ %{}
      ) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:country, country)
      |> Map.put(:phone_number, phone)
      |> Map.put(:send_attempt, send_attempt)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register/msisdn/requestToken",
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

  @doc """
  Returns a `%Request{}` struct used to change the password for an account on the homeserver.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver 
  - `new_password`: the desired password for the account
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Auth`

  Optional: 
  - `logout_devices`: `true` or `false`, whether the user's other access tokens, and their associated devices, should be revoked if the request succeeds

  ## Examples 

      iex> auth = MatrixSDK.Auth.login_token("token")
      iex> MatrixSDK.Request.change_password("https://matrix.org", "new_password", auth)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          auth: %{token: "token", type: "m.login.token"},
          new_password: "new_password"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password"
      }
  """
  @spec change_password(base_url, binary, Auth.t(), map) :: t
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

  @doc """
  Returns a `%Request{}` struct used to request validation tokens when authenticating for `change_password`. 

  ## Examples

      iex> MatrixSDK.Request.password_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", email: "maurice@moss.yay", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password/email/requestToken"
      }
  """
  @spec password_email_token(base_url, binary, binary, pos_integer, map) :: t
  def password_email_token(base_url, client_secret, email, send_attempt, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:email, email)
      |> Map.put(:send_attempt, send_attempt)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/password/email/requestToken",
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to request validation tokens when authenticating for `change_password`. 

  ## Examples

      iex> MatrixSDK.Request.password_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", country: "GB", phone_number: "07700900001", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password/msisdn/requestToken"
      }
  """
  @spec password_msisdn_token(base_url, binary, binary, pos_integer, map) :: t
  def password_msisdn_token(base_url, client_secret, country, phone, send_attempt, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:country, country)
      |> Map.put(:phone_number, phone)
      |> Map.put(:send_attempt, send_attempt)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/password/msisdn/requestToken",
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get a list of the third party identifiers the homeserver has associated with the user's account.

  ## Examples

      iex> MatrixSDK.Request.account_3pids("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/account/3pid"
      }
  """
  @spec account_3pids(base_url, binary) :: t
  def account_3pids(base_url, token),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid",
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Gets a list of the third party identifiers the homeserver has associated with the user's account.

  ## Examples

      iex> MatrixSDK.Request.account_3pids("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/account/3pid"
      }
  """
  @spec account_add_3pid(base_url, Auth.t(), binary, binary, binary) :: t
  def account_add_3pid(base_url, auth, client_secret, sid, token) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:sid, sid)
      |> Map.put(:auth, auth)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/add",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get information about the owner of a given access token.

  ## Examples

      iex> MatrixSDK.Request.whoami("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/account/whoami"
      }
  """
  @spec whoami(base_url, binary) :: t
  def whoami(base_url, token),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/account/whoami",
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Returns a `%Request{}` struct used to synchronises the client's state with the latest state on the server.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver 
  - `token`: the authentication token returned from user login 

  Optional:
  - `filter`: the ID of a filter created using the filter API or a filter JSON object encoded as a string
  - `since`: a point in time to continue a sync from (usuall the `next_batch` value from last sync)
  - `full_state`: controls whether to include the full state for all rooms the user is a member of
  - `set_presence`: controls whether the client is automatically marked as online by polling this API
  - `timeout`: the maximum time to wait, in milliseconds, before returning this request

  ## Examples

      iex> MatrixSDK.Request.sync("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/sync",
        query_params: []
      }

  With optional parameters:

      iex> opts = %{
      ...>          since: "s123456789",
      ...>          filter: "filter",
      ...>          full_state: true,
      ...>          set_presence: "online",
      ...>          timeout: 1000
      ...>         }
      iex> MatrixSDK.Request.sync("https://matrix.org", "token", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/sync",
        query_params: [
          {:filter, "filter"},
          {:full_state, true}, 
          {:set_presence, "online"}, 
          {:since, "s123456789"}, 
          {:timeout, 1000}
        ]
      }
  """
  @spec sync(base_url, binary, map) :: t
  def sync(base_url, token, opts \\ %{}),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/sync",
      query_params: Map.to_list(opts),
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Returns a `%Request{}` struct used to get a single event based on `room_id` and `event_id`.

  ## Example

      iex> MatrixSDK.Request.room_event("https://matrix.org", "token", "!someroom:matrix.org", "$someevent")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/event/%24someevent",
        query_params: %{}
      }
  """
  @spec room_event(base_url, binary, binary, binary) :: t
  def room_event(base_url, token, room_id, event_id) do
    encoded_room_id = URI.encode_www_form(room_id)
    encoded_event_id = URI.encode_www_form(event_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/event/#{encoded_event_id}",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to look up the contents of a state event in a room.

  ## Example

      iex> MatrixSDK.Request.room_state_event("https://matrix.org", "token", "!someroom:matrix.org", "m.room.member", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state/m.room.member/%40user%3Amatrix.org",
        query_params: %{}
      }
  """
  @spec room_state_event(base_url, binary, binary, binary, binary) :: t
  def room_state_event(base_url, token, room_id, event_type, state_key) do
    encoded_room_id = URI.encode_www_form(room_id)
    encoded_state_key = URI.encode_www_form(state_key)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path:
        "/_matrix/client/r0/rooms/#{encoded_room_id}/state/#{event_type}/#{encoded_state_key}",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
    Returns a `%Request{}` struct used to get the state events for the current state of a room.

  ## Example 

      iex> MatrixSDK.Request.room_state("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state",
        query_params: %{}
      }
  """
  @spec room_state(base_url, binary, binary) :: t
  def room_state(base_url, token, room_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/state",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get the list of members for this room.

  ## Example 

      iex> MatrixSDK.Request.room_members("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/members",
        query_params: []
      }

  With optional parameters:

      iex> opts = %{
      ...>          at: "t123456789",
      ...>          membership: "join",
      ...>          not_membership: "invite"
      ...>        }
      iex> MatrixSDK.Request.room_members("https://matrix.org", "token", "!someroom:matrix.org", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/members",
        query_params: [at: "t123456789", membership: "join", not_membership: "invite"]
      }
  """
  @spec room_members(base_url, binary, binary) :: t
  def room_members(base_url, token, room_id, opts \\ %{}) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/members",
      query_params: Map.to_list(opts),
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get a map of MXIDs to member info objects for members of the room.

  ## Example 

      iex> MatrixSDK.Request.room_joined_members("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/joined_members",
        query_params: %{}
      }
  """
  @spec room_joined_members(base_url, binary, binary) :: t
  def room_joined_members(base_url, token, room_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/joined_members",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get message and state events for a room. 
  It uses pagination query parameters to paginate history in the room.

  ## Example 

      iex> MatrixSDK.Request.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/messages",
        query_params: [dir: "f", from: "t123456789"]
      }

  With optional parameters:

      iex> opts = %{
      ...>          to: "t123456789",
      ...>          limit: 10,
      ...>          filter: "filter"
      ...>        }
      iex> MatrixSDK.Request.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/messages",
        query_params: [dir: "f", filter: "filter", from: "t123456789", limit: 10, to: "t123456789"]
      }
  """
  @spec room_messages(base_url, binary, binary, binary, binary, map) :: t
  def room_messages(base_url, token, room_id, from, dir, opts \\ %{}) do
    encoded_room_id = URI.encode_www_form(room_id)

    query_params =
      %{}
      |> Map.put(:from, from)
      |> Map.put(:dir, dir)
      |> Map.merge(opts)
      |> Map.to_list()

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/messages",
      query_params: query_params,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to send a state event to a room. 

  ## Example

      iex> state_event = %{
      ...>                content: %{join_rule: "private"},
      ...>                room_id: "!someroom:matrix.org",
      ...>                state_key: "",
      ...>                type: "m.room.join_rules"
      ...>              }
      iex> MatrixSDK.Request.send_state_event("https://matrix.org", "token", state_event)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{join_rule: "private"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state/m.room.join_rules/",
        query_params: %{}
      }
  """
  @spec send_state_event(base_url, binary, StateEvent.t()) :: t
  def send_state_event(base_url, token, state_event) do
    encoded_room_id = URI.encode_www_form(state_event.room_id)
    encoded_event_type = URI.encode_www_form(state_event.type)
    encoded_state_key = URI.encode_www_form(state_event.state_key)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path:
        "/_matrix/client/r0/rooms/#{encoded_room_id}/state/#{encoded_event_type}/#{
          encoded_state_key
        }",
      headers: [{"Authorization", "Bearer " <> token}],
      body: state_event.content
    }
  end

  @doc """
  Returns a `%Request{}` struct used to send a room event to a room. 

  ## Example

      iex> room_event = %{
      ...>                content: %{body: "Fire! Fire! Fire!", msgtype: "m.text"},
      ...>                room_id: "!someroom:matrix.org",
      ...>                type: "m.room.message",
      ...>                transaction_id: "transaction_id"
      ...>              }
      iex> MatrixSDK.Request.send_room_event("https://matrix.org", "token", room_event)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{body: "Fire! Fire! Fire!", msgtype: "m.text"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/send/m.room.message/transaction_id",
        query_params: %{}
      }
  """
  @spec send_room_event(base_url, binary, RoomEvent.t()) :: t
  def send_room_event(base_url, token, room_event) do
    encoded_room_id = URI.encode_www_form(room_event.room_id)
    encoded_event_type = URI.encode_www_form(room_event.type)
    encoded_transaction_id = URI.encode_www_form(room_event.transaction_id)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path:
        "/_matrix/client/r0/rooms/#{encoded_room_id}/send/#{encoded_event_type}/#{
          encoded_transaction_id
        }",
      headers: [{"Authorization", "Bearer " <> token}],
      body: room_event.content
    }
  end

  @doc """
  Returns a `%Request{}` struct used to redact a room event. 

  ## Example

      iex> MatrixSDK.Request.redact_room_event("https://matrix.org", "token", "!someroom:matrix.org", "event_id", "transaction_id")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id",
      }

  With options:

      iex> opt = %{reason: "Indecent material"}
      iex> MatrixSDK.Request.redact_room_event("https://matrix.org", "token", "!someroom:matrix.org", "event_id", "transaction_id", opt)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{reason: "Indecent material"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id",
      }
  """
  @spec redact_room_event(base_url, binary, binary, binary, binary, map) :: t
  def redact_room_event(base_url, token, room_id, event_id, transaction_id, opt \\ %{}) do
    encoded_room_id = URI.encode_www_form(room_id)
    encoded_event_id = URI.encode_www_form(event_id)
    encoded_transaction_id = URI.encode_www_form(transaction_id)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path:
        "/_matrix/client/r0/rooms/#{encoded_room_id}/redact/#{encoded_event_id}/#{
          encoded_transaction_id
        }",
      headers: [{"Authorization", "Bearer " <> token}],
      body: opt
    }
  end

  @doc """
  Returns a `%Request{}` struct used to create a new room. 

  ## Examples

      iex> MatrixSDK.Request.create_room("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/createRoom"
      }

  With options:
      
      iex> opts = %{
      ...>          visibility: "public",
      ...>          room_alias_name: "chocolate",
      ...>          topic: "Some cool stuff about chocolate."
      ...>        }
      iex> MatrixSDK.Request.create_room("https://matrix.org", "token", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{room_alias_name: "chocolate", topic: "Some cool stuff about chocolate.", visibility: "public"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/createRoom"
      }
  """
  @spec create_room(base_url, binary, map) :: t
  def create_room(base_url, token, opts \\ %{}),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/createRoom",
      headers: [{"Authorization", "Bearer " <> token}],
      body: opts
    }

  @doc """
  Returns a `%Request{}` struct used to get a list of the user's current rooms.

  ## Example

        iex> MatrixSDK.Request.joined_rooms("https://matrix.org", "token")
        %MatrixSDK.Request{
          base_url: "https://matrix.org",
          body: %{},
          headers: [{"Authorization", "Bearer token"}],
          method: :get,
          path: "/_matrix/client/r0/joined_rooms",
        }
  """
  @spec joined_rooms(base_url, binary) :: t
  def joined_rooms(base_url, token),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/joined_rooms",
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Returns a `%Request{}` struct used to invite a user to participate in a room.

  ## Examples

      iex> MatrixSDK.Request.room_invite("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{user_id: "@user:matrix.org"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/invite",
      }
  """
  @spec room_invite(base_url, binary, binary, binary) :: t
  def room_invite(base_url, token, room_id, user_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/invite",
      headers: [{"Authorization", "Bearer " <> token}],
      body: %{user_id: user_id}
    }
  end

  @doc """
  Returns a `%Request{}` struct used by a user to join a room.

  ## Example 

      iex> MatrixSDK.Request.join_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/join/%21someroom%3Amatrix.org",
      }

  TODO: add example for 3pids
  """
  @spec join_room(base_url, binary, binary, map) :: t
  def join_room(base_url, token, room_id_or_alias, opts \\ %{}) do
    encoded_room_id_or_alias = URI.encode_www_form(room_id_or_alias)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/join/#{encoded_room_id_or_alias}",
      headers: [{"Authorization", "Bearer " <> token}],
      body: opts
    }
  end

  @doc """
  Returns a `%Request{}` struct used to leave a room.

  ## Examples

      iex> MatrixSDK.Request.leave_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/leave",
      }
  """
  @spec leave_room(base_url, binary, binary) :: t
  def leave_room(base_url, token, room_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/leave",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to forget a room.

  ## Examples

      iex> MatrixSDK.Request.forget_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/forget",
      }
  """
  @spec forget_room(base_url, binary, binary) :: t
  def forget_room(base_url, token, room_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/forget",
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to kick a user from a room.

  ## Examples

      iex> MatrixSDK.Request.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/kick",
        body: %{user_id: "@user:matrix.org"}
      }

      iex> MatrixSDK.Request.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/kick",
        body: %{user_id: "@user:matrix.org", reason: "Ate all the chocolate"}
      }
  """
  @spec room_kick(base_url, binary, binary, binary, map) :: t
  def room_kick(base_url, token, room_id, user_id, opt \\ %{}) do
    encoded_room_id = URI.encode_www_form(room_id)

    body =
      %{}
      |> Map.put(:user_id, user_id)
      |> Map.merge(opt)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/kick",
      headers: [{"Authorization", "Bearer " <> token}],
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to ban a user from a room.

  ## Examples

      iex> MatrixSDK.Request.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/ban",
        body: %{user_id: "@user:matrix.org"}
      }

      iex> MatrixSDK.Request.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/ban",
        body: %{user_id: "@user:matrix.org", reason: "Ate all the chocolate"}
      }
  """
  @spec room_ban(base_url, binary, binary, binary, map) :: t
  def room_ban(base_url, token, room_id, user_id, opt \\ %{}) do
    encoded_room_id = URI.encode_www_form(room_id)

    body =
      %{}
      |> Map.put(:user_id, user_id)
      |> Map.merge(opt)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/ban",
      headers: [{"Authorization", "Bearer " <> token}],
      body: body
    }
  end

  @doc """
  Returns a `%Request{}` struct used to unban a user from a room.

  ## Examples

      iex> MatrixSDK.Request.room_unban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/unban",
        body: %{user_id: "@user:matrix.org"}
      }
  """
  @spec room_unban(base_url, binary, binary, binary) :: t
  def room_unban(base_url, token, room_id, user_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/rooms/#{encoded_room_id}/unban",
      headers: [{"Authorization", "Bearer " <> token}],
      body: %{user_id: user_id}
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get the visibility of a given room on the server's public room directory.

  ## Example

      iex> MatrixSDK.Request.room_visibility("https://matrix.org", "!someroom:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        method: :get,
        path: "/_matrix/client/r0/directory/list/room/%21someroom%3Amatrix.org",
      }
  """
  @spec room_visibility(base_url, binary) :: t
  def room_visibility(base_url, room_id) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/directory/list/room/#{encoded_room_id}"
    }
  end

  @doc """
  Returns a `%Request{}` struct used to set the visibility of a given room in the server's public room directory.

  ## Example

      iex> MatrixSDK.Request.room_visibility("https://matrix.org", "token", "!someroom:matrix.org", "private")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{visibility: "private"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/directory/list/room/%21someroom%3Amatrix.org",
      }
  """
  @spec room_visibility(base_url, binary, binary, binary) :: t
  def room_visibility(base_url, token, room_id, visibility) do
    encoded_room_id = URI.encode_www_form(room_id)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path: "/_matrix/client/r0/directory/list/room/#{encoded_room_id}",
      headers: [{"Authorization", "Bearer " <> token}],
      body: %{visibility: visibility}
    }
  end

  @doc """
  Returns a `%Request{}` struct used to list the public rooms on the server with basic filtering.

  ## Examples

      iex> MatrixSDK.Request.public_rooms("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/publicRooms",
        query_params: []
      }

  With optional parameters:   

      iex> MatrixSDK.Request.public_rooms("https://matrix.org", %{limit: 10})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/publicRooms",
        query_params: [limit: 10]
      }
  """
  @spec public_rooms(base_url, map) :: t
  def public_rooms(base_url, opts \\ %{}),
    do: %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/publicRooms",
      query_params: Map.to_list(opts)
    }

  @doc """
  Returns a `%Request{}` struct used to list the public rooms on the server with more advanced filtering options. 

  ## Examples

      iex> MatrixSDK.Request.public_rooms("https://matrix.org", "token", %{limit: 10})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{limit: 10},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/publicRooms",
        query_params: []
      }

  With optional parameter:

      iex> MatrixSDK.Request.public_rooms("https://matrix.org", "token", %{limit: 10}, "server")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{limit: 10},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/publicRooms",
        query_params: [server: "server"]
      }
  """
  @spec public_rooms(base_url, binary, map, binary) :: t
  def public_rooms(base_url, token, filters, server \\ nil) do
    query_params = if server, do: [server: server], else: []

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/publicRooms",
      query_params: query_params,
      headers: [{"Authorization", "Bearer " <> token}],
      body: filters
    }
  end

  @doc """
  Returns a `%Request{}` struct used to search for users.

  ## Examples

      iex> MatrixSDK.Request.user_directory_search("https://matrix.org", "token", "mickey")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{search_term: "mickey"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/user_directory/search",
      }

  With limit option:

      iex> MatrixSDK.Request.user_directory_search("https://matrix.org", "token", "mickey", %{limit: 42})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{search_term: "mickey", limit: 42},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/user_directory/search",
      }

  With language option:

      iex> MatrixSDK.Request.user_directory_search("https://matrix.org", "token", "mickey", %{language: "en-US"})
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{search_term: "mickey"},
        headers: [{"Authorization", "Bearer token"}, {"Accept-Language", "en-US"}],
        method: :post,
        path: "/_matrix/client/r0/user_directory/search",
      }
  """
  @spec user_directory_search(base_url, binary, binary, map) :: t
  def user_directory_search(base_url, token, search_term, opts \\ %{}) do
    {headers, body} =
      case opts do
        %{language: language, limit: limit} ->
          {[{"Accept-Language", language}], %{limit: limit}}

        %{language: language} ->
          {[{"Accept-Language", language}], %{}}

        %{limit: limit} ->
          {[], %{limit: limit}}

        _ ->
          {[], %{}}
      end

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/user_directory/search",
      headers: [{"Authorization", "Bearer " <> token}] ++ headers,
      body: Map.put(body, :search_term, search_term)
    }
  end

  @doc """
  Returns a `%Request{}` struct used to set the display name for a user.

  ## Examples

      iex> MatrixSDK.Request.set_display_name("https://matrix.org", "token", "@user:matrix.org", "mickey")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{displayname: "mickey"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/profile/%40user%3Amatrix.org/displayname",
      }
  """
  @spec set_display_name(base_url, binary, binary, binary) :: t
  def set_display_name(base_url, token, user_id, display_name) do
    encoded_user_id = URI.encode_www_form(user_id)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path: "/_matrix/client/r0/profile/#{encoded_user_id}/displayname",
      headers: [{"Authorization", "Bearer " <> token}],
      body: %{displayname: display_name}
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get the display name for a user.

  ## Examples

      iex> MatrixSDK.Request.display_name("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        method: :get,
        path: "/_matrix/client/r0/profile/%40user%3Amatrix.org/displayname",
      }
  """
  @spec display_name(base_url, binary) :: t
  def display_name(base_url, user_id) do
    encoded_user_id = URI.encode_www_form(user_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/profile/#{encoded_user_id}/displayname"
    }
  end

  @doc """
  Returns a `%Request{}` struct used to set the avatar url for a user.

  ## Examples

      iex> MatrixSDK.Request.set_avatar_url("https://matrix.org", "token", "@user:matrix.org", "mxc://matrix.org/wefh34uihSDRGhw34")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        method: :put,
        path: "/_matrix/client/r0/profile/%40user%3Amatrix.org/avatar_url",
        body: %{avatar_url: "mxc://matrix.org/wefh34uihSDRGhw34"},
        headers: [{"Authorization", "Bearer token"}],
      }
  """
  @spec set_avatar_url(base_url, binary, binary, binary) :: t
  def set_avatar_url(base_url, token, user_id, avatar_url) do
    encoded_user_id = URI.encode_www_form(user_id)

    %__MODULE__{
      method: :put,
      base_url: base_url,
      path: "/_matrix/client/r0/profile/#{encoded_user_id}/avatar_url",
      headers: [{"Authorization", "Bearer " <> token}],
      body: %{avatar_url: avatar_url}
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get the avatar url for a user.

  ## Examples

      iex> MatrixSDK.Request.avatar_url("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        method: :get,
        path: "/_matrix/client/r0/profile/%40user%3Amatrix.org/avatar_url",
      }
  """
  @spec avatar_url(base_url, binary) :: t
  def avatar_url(base_url, user_id) do
    encoded_user_id = URI.encode_www_form(user_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/profile/#{encoded_user_id}/avatar_url"
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get the user profile for a given user id.

  ## Examples

      iex> MatrixSDK.Request.user_profile("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        method: :get,
        path: "/_matrix/client/r0/profile/%40user%3Amatrix.org",
      }
  """
  @spec user_profile(base_url, binary) :: t
  def user_profile(base_url, user_id) do
    encoded_user_id = URI.encode_www_form(user_id)

    %__MODULE__{
      method: :get,
      base_url: base_url,
      path: "/_matrix/client/r0/profile/#{encoded_user_id}"
    }
  end
end
