defmodule MatrixSDK.Client.Request do
  @moduledoc """
  Provides functions which return a struct containing the data necessary for
  each HTTP request.
  """

  alias MatrixSDK.Client.{Auth, RoomEvent, StateEvent}

  @enforce_keys [:method, :base_url, :path]
  defstruct([:method, :base_url, :path, query_params: [], headers: [], body: %{}])

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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.

  ## Examples

      iex> MatrixSDK.Client.Request.spec_versions("https://matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/versions",
        query_params: []
      }
  """
  @spec spec_versions(base_url) :: t
  def spec_versions(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/versions"}

  @doc """
  Returns a `%Request{}` struct used to get discovery information about the domain.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 

  ## Examples

      iex> MatrixSDK.Client.Request.server_discovery("https://matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/.well-known/matrix/client",
        query_params: []
      }
  """
  @spec server_discovery(base_url) :: t
  def server_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/.well-known/matrix/client"}

  @doc """
  Returns a `%Request{}` struct used to get information about the server's supported feature set and other relevant capabilities.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      iex> MatrixSDK.Client.Request.server_capabilities("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/capabilities",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver.

  ## Examples

      iex> MatrixSDK.Client.Request.login("https://matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/login",
        query_params: []
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
  - `base_url`: the base URL for the homeserver. 
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  Optional:
  - `device_id`: ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a `device_id` if this is not specified.
  - `initial_device_display_name`: a display name to assign to the newly-created device.


  ## Examples
      
  Token authentication:
      iex> auth = MatrixSDK.Client.Auth.login_token("token")
      iex> MatrixSDK.Client.Request.login("https://matrix.org", auth)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{token: "token", type: "m.login.token"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/login",
        query_params: []
      }

  User and password authentication with optional parameters:

      iex> auth = MatrixSDK.Client.Auth.login_user("maurice_moss", "password")
      iex> opts = %{device_id: "id", initial_device_display_name: "THE INTERNET"}
      iex> MatrixSDK.Client.Request.login("https://matrix.org", auth, opts)
      %MatrixSDK.Client.Request{
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
        path: "/_matrix/client/r0/login",
        query_params: []
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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples
      iex> MatrixSDK.Client.Request.logout("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout",
        query_params: []
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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      iex> MatrixSDK.Client.Request.logout_all("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout/all",
        query_params: []
      }
  """
  @spec logout_all(base_url, binary) :: t
  def logout_all(base_url, token), do: logout(base_url, "/_matrix/client/r0/logout/all", token)

  @doc """
  Returns a `%Request{}` struct used to register a guest account on the homeserver and returns an access token which can be used to authenticate subsequent requests. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 

  Optional: 
  - `initial_device_display_name`: a display name to assign to the newly-created device.

  ## Examples

      iex> MatrixSDK.Client.Request.register_guest("https://matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest",
        query_params: []
      }   

  Specifiying a display name for the device:    

      iex> opts = %{initial_device_display_name: "THE INTERNET"}
      iex> MatrixSDK.Client.Request.register_guest("https://matrix.org", opts)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{initial_device_display_name: "THE INTERNET"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest",
        query_params: []
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
  - `base_url`: the base URL for the homeserver. 
  - `password`: the desired password for the account.
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  Optional: 
  - `username`: the basis for the localpart of the desired Matrix ID. If omitted, the homeserver will generate a Matrix ID local part.
  - `device_id`: ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a `device_id` if this is not specified.
  - `initial_device_display_name`: a display name to assign to the newly-created device.
  - `inhibit_login`: if true, an `access_token` and `device_id` will not be returned from this call, therefore preventing an automatic login.

  ## Examples

      iex> auth = MatrixSDK.Client.Auth.login_dummy()
      iex> MatrixSDK.Client.Request.register_user("https://matrix.org", "password", auth)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{auth: %{type: "m.login.dummy"}, password: "password"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register",
        query_params: []
      }

  With optional parameters:    

      iex> auth = MatrixSDK.Client.Auth.login_dummy()
      iex> opts = %{
      ...>          username: "maurice_moss",
      ...>          device_id: "id",
      ...>          initial_device_display_name: "THE INTERNET",
      ...>          inhibit_login: true
      ...>        }
      iex> MatrixSDK.Client.Request.register_user("https://matrix.org", "password", auth, opts)
      %MatrixSDK.Client.Request{
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
        path: "/_matrix/client/r0/register",
        query_params: []
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

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `email`: the email address.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL.  

  ## Examples

      iex> MatrixSDK.Client.Request.registration_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", email: "maurice@moss.yay", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/email/requestToken",
        query_params: []
      }

  With optional parameters:

      iex> opts = %{next_link: "nextlink.url"}
      iex> MatrixSDK.Client.Request.registration_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1, opts)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "secret",
          email: "maurice@moss.yay",
          send_attempt: 1, 
          next_link: "nextlink.url"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/email/requestToken",
        query_params: []
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
  Returns a `%Request{}` struct used to check the given phone number is not already associated with an account on the homeserver. This should be used to get a token to register a phone number as part of the initial user registration.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `country`: the two-letter uppercase ISO-3166-1 alpha-2 country code.
  - `phone`: the phone number.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL. 

  ## Examples

      iex> MatrixSDK.Client.Request.registration_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "secret", 
          country: "GB", 
          phone_number: "07700900001", 
          send_attempt: 1
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register/msisdn/requestToken",
        query_params: []
      }

  With optional parameters:

      iex> opts = %{next_link: "nextlink.url"}
      iex> MatrixSDK.Client.Request.registration_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1, opts)
      %MatrixSDK.Client.Request{
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
        path: "/_matrix/client/r0/register/msisdn/requestToken",
        query_params: []
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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `username`: the basis for the localpart of the desired Matrix ID. 

  ## Examples

       iex> MatrixSDK.Client.Request.username_availability("https://matrix.org", "maurice_moss")
       %MatrixSDK.Client.Request{
         base_url: "https://matrix.org",
         body: %{},
         headers: [],
         method: :get,
         path: "/_matrix/client/r0/register/available?username=maurice_moss",
         query_params: []
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
  Returns a `%Request{}` struct used to change the password for an account on the homeserver. This request needs to be authenticated with `m.login.email.identity` or `m.login.msisdn.identity`. For more info see _3PID API flows_ section on the `MatrixSDK.Client` module.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.   
  - `new_password`: the desired password for the account.
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  Optional: 
  - `logout_devices`: `true` or `false`, whether the user's other access tokens, and their associated devices, should be revoked if the request succeeds.

  ## Examples 

      iex> auth = MatrixSDK.Client.Auth.login_email_identity("sid", "client_secret")
      iex> MatrixSDK.Client.Request.change_password("https://matrix.org", "new_password", auth)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          auth: %{
            type: "m.login.email.identity", 
            threepidCreds: [%{client_secret: "client_secret", sid: "sid"}]
          },
          new_password: "new_password"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password",
        query_params: []
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
  Returns a `%Request{}` struct used to request validation tokens when authenticating for `change_password/4`.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `email`: the email address.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL.  

  ## Examples

      iex> MatrixSDK.Client.Request.password_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", email: "maurice@moss.yay", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password/email/requestToken",
        query_params: []
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
  Returns a `%Request{}` struct used to request validation tokens when authenticating for `change_password/4`.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `country`: the two-letter uppercase ISO-3166-1 alpha-2 country code.
  - `phone`: the phone number.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL. 

  ## Examples

      iex> MatrixSDK.Client.Request.password_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{client_secret: "secret", country: "GB", phone_number: "07700900001", send_attempt: 1},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/account/password/msisdn/requestToken",
        query_params: []
      }
  """
  @spec password_msisdn_token(base_url, binary, binary, binary, pos_integer, map) :: t
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
  Returns a `%Request{}` struct used to deactivate a user's account. 

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  Optional: 
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  ## Examples

      iex> MatrixSDK.Client.Request.deactivate_account("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/deactivate",
        query_params: []
      }
  """
  @spec deactivate_account(base_url, binary, map) :: t
  def deactivate_account(base_url, token, opts \\ %{}),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/deactivate",
      headers: [{"Authorization", "Bearer " <> token}],
      body: opts
    }

  @doc """
  Returns a `%Request{}` struct used to get a list of the third party identifiers the homeserver has associated with the user's account.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      iex> MatrixSDK.Client.Request.account_3pids("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/account/3pid",
        query_params: []
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
  Returns a `%Request{}` struct used to add contact information to the user's account.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: the client secret used in the session with the homeserver.
  - `sid`: the session ID give by the homeserver. 

  Optional:
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module.

  ## Examples

      iex> MatrixSDK.Client.Request.account_add_3pid("https://matrix.org", "token", "client_secret", "sid")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          sid: "sid"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/add",
        query_params: []
      }
  """
  @spec account_add_3pid(base_url, binary, binary, binary, map) :: t
  def account_add_3pid(base_url, token, client_secret, sid, opts \\ %{}) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:sid, sid)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/add",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to bind contact information to the user's account through the specified identity server.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: the client secret used in the session with the identity server.
  - `id_server`: the identity server to use.
  - `id_access_token`: an access token previously registered with the identity server.
  - `sid`: he session ID given by the identity server.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module.

  ## Examples

      iex> MatrixSDK.Client.Request.account_bind_3pid("https://matrix.org", "token", "client_secret", "example.org", "abc123", "sid")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          sid: "sid",
          id_server: "example.org",
          id_access_token: "abc123"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/bind",
        query_params: []
      }
  """
  @spec account_bind_3pid(base_url, binary, binary, binary, binary, binary) :: t
  def account_bind_3pid(base_url, token, client_secret, id_server, id_access_token, sid) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:sid, sid)
      |> Map.put(:id_server, id_server)
      |> Map.put(:id_access_token, id_access_token)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/bind",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to delete contact information from the user's account.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `medium`: the medium of the third party identifier being removed. One of: `"email"` or `"msisdn"`.
  - `address`: the third party address being removed.

  Optional: 

  - `id_server`: the identity server to unbind from.

  ## Examples

      iex> MatrixSDK.Client.Request.account_delete_3pid("https://matrix.org", "token", "email", "example@example.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          medium: "email",
          address: "example@example.org"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/delete",
        query_params: []
      }

  With optional `id_server` parameter:

      iex> MatrixSDK.Client.Request.account_delete_3pid("https://matrix.org", "token", "email", "example@example.org", %{id_server: "example.org"})
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          medium: "email",
          address: "example@example.org",
          id_server: "example.org"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/delete",
        query_params: []
      }  
  """
  @spec account_delete_3pid(base_url, binary, binary, binary, map) :: t
  def account_delete_3pid(base_url, token, medium, address, opt \\ %{}) do
    body =
      %{}
      |> Map.put(:medium, medium)
      |> Map.put(:address, address)
      |> Map.merge(opt)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/delete",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to unbind contact information from the user's account without deleting it from the homeserver.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `medium`: the medium of the third party identifier being removed. One of: `"email"` or `"msisdn"`.
  - `address`: the third party address being removed. 

  Optional:
  - `id_server`: the identity server to unbind from.

  ## Examples

      iex> MatrixSDK.Client.Request.account_unbind_3pid("https://matrix.org", "token", "email", "example@example.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          medium: "email",
          address: "example@example.org"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/unbind",
        query_params: []
      }

  With optional `id_server` parameter:

      iex> MatrixSDK.Client.Request.account_unbind_3pid("https://matrix.org", "token", "email", "example@example.org", %{id_server: "example.org"})
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          medium: "email",
          address: "example@example.org",
          id_server: "example.org"
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/unbind",
        query_params: []
      }  
  """
  @spec account_unbind_3pid(base_url, binary, binary, binary, map) :: t
  def account_unbind_3pid(base_url, token, medium, address, opt \\ %{}) do
    body =
      %{}
      |> Map.put(:medium, medium)
      |> Map.put(:address, address)
      |> Map.merge(opt)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/unbind",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to request a validation token when adding an email to a user's account.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `email`: the email address.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL.  

  ## Examples

      iex> MatrixSDK.Client.Request.account_email_token("https://matrix.org", "token", "client_secret", "example@example.org", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          email: "example@example.org",
          send_attempt: 1
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/email/requestToken",
        query_params: []
      }

  With optional parameter:

      iex> opt = %{next_link: "test-site.url"}
      iex> MatrixSDK.Client.Request.account_email_token("https://matrix.org", "token", "client_secret", "example@example.org", 1, opt)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          email: "example@example.org",
          next_link: "test-site.url",
          send_attempt: 1
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/email/requestToken",
        query_params: []
      }
  """
  @spec account_email_token(base_url, binary, binary, binary, pos_integer, map) :: t
  def account_email_token(
        base_url,
        token,
        client_secret,
        email,
        send_attempt,
        opts \\ %{}
      ) do
    body =
      %{}
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:email, email)
      |> Map.put(:send_attempt, send_attempt)
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/account/3pid/email/requestToken",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to request a validation token when adding a phone number to a user's account.

  For more info see _3PID API flows_ section on the `MatrixSDK.Client` module. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `country`: the two-letter uppercase ISO-3166-1 alpha-2 country code.
  - `phone`: the phone number.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL.

  ## Examples

      iex> MatrixSDK.Client.Request.account_msisdn_token("https://matrix.org", "token", "client_secret", "GB", "07700900001", 1)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          country: "GB",
          phone_number: "07700900001",
          send_attempt: 1
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/msisdn/requestToken",
        query_params: []
      }

  With optional parameter:

      iex> opt = %{next_link: "test-site.url"}
      iex> MatrixSDK.Client.Request.account_msisdn_token("https://matrix.org", "token", "client_secret", "GB", "07700900001", 1, opt)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{
          client_secret: "client_secret",
          country: "GB",
          phone_number: "07700900001",
          next_link: "test-site.url",
          send_attempt: 1
        },
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/account/3pid/msisdn/requestToken",
        query_params: []
      }
  """
  @spec account_msisdn_token(
          base_url,
          binary,
          binary,
          binary,
          binary,
          pos_integer,
          map
        ) :: t
  def account_msisdn_token(
        base_url,
        token,
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
      path: "/_matrix/client/r0/account/3pid/msisdn/requestToken",
      body: body,
      headers: [{"Authorization", "Bearer " <> token}]
    }
  end

  @doc """
  Returns a `%Request{}` struct used to get information about the owner of a given access token.

  ## Args

  Required: 

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      iex> MatrixSDK.Client.Request.whoami("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/account/whoami",
        query_params: []
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
  - `base_url`: the base URL for the homeserver. 
  - `token`: the authentication token returned from user login. 

  Optional:
  - `filter`: the ID of a filter created using the filter API or a filter JSON object encoded as a string.
  - `since`: a point in time to continue a sync from (usuall the `next_batch` value from last sync).
  - `full_state`: controls whether to include the full state for all rooms the user is a member of.
  - `set_presence`: controls whether the client is automatically marked as online by polling this API.
  - `timeout`: the maximum time to wait, in milliseconds, before returning this request.

  ## Examples

      iex> MatrixSDK.Client.Request.sync("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
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
      iex> MatrixSDK.Client.Request.sync("https://matrix.org", "token", opts)
      %MatrixSDK.Client.Request{
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

  ## Args

  Required:

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the ID of the room the event is in. 
  - `event_id`: the event ID.

  ## Example

      iex> MatrixSDK.Client.Request.room_event("https://matrix.org", "token", "!someroom:matrix.org", "$someevent")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/event/%24someevent",
        query_params: []
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

  ## Args

  Required:

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room the state event is in.
  - `event_type`: the type of the state event.
  - `state_key`: the key of the state to look up. Often an empty string.

  ## Example

      iex> MatrixSDK.Client.Request.room_state_event("https://matrix.org", "token", "!someroom:matrix.org", "m.room.member", "@user:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state/m.room.member/%40user%3Amatrix.org",
        query_params: []
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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room the events are in. 

  ## Example 

      iex> MatrixSDK.Client.Request.room_state("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  Optional: 
  - `at`: the point in time (pagination token) to return members for in the room.
  - `membership`: the kind of membership to filter for. Defaults to no filtering if unspecified.
  - `not_membership`: the kind of membership to exclude from the results. Defaults to no filtering if unspecified. One of: `"join"`, `"invite"`, `"leave"`, `"ban"`.

  ## Examples

      iex> MatrixSDK.Client.Request.room_members("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
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
      iex> MatrixSDK.Client.Request.room_members("https://matrix.org", "token", "!someroom:matrix.org", opts)
      %MatrixSDK.Client.Request{
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Example 

      iex> MatrixSDK.Client.Request.room_joined_members("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :get,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/joined_members",
        query_params: []
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
  It uses pagination parameters to paginate history in the room.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID. 
  - `from`: the pagination token to start returning events from.
  - `dir`: the direction to return events from. One of: `"b"` or `"f"`.

  Optional: 
  - `to`: the pagination token to stop returning events at.
  - `limit`: the maximum number of events to return. 
  - `filter`: a filter to apply to the returned events. 

  ## Examples 

      iex> MatrixSDK.Client.Request.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f")
      %MatrixSDK.Client.Request{
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
      iex> MatrixSDK.Client.Request.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f", opts)
      %MatrixSDK.Client.Request{
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `state_event`: a state event as defined in `MatrixSDK.Client.StateEvent`. 

  ## Example

      iex> state_event = MatrixSDK.Client.StateEvent.join_rules("!someroom:matrix.org", "private")
      iex> MatrixSDK.Client.Request.send_state_event("https://matrix.org", "token", state_event)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{join_rule: "private"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state/m.room.join_rules/",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_event`: a state event as defined in `MatrixSDK.Client.RoomEvent`. 

  ## Example

      iex> room_event = MatrixSDK.Client.RoomEvent.message("!someroom:matrix.org", :text, "Fire! Fire! Fire!", "transaction_id")
      iex> MatrixSDK.Client.Request.send_room_event("https://matrix.org", "token", room_event)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{body: "Fire! Fire! Fire!", msgtype: "m.text"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/send/m.room.message/transaction_id",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID. 
  - `event_id`: the event ID.
  - `transaction_id`: the transaction ID for this event. Clients should generate a unique ID; it will be used by the server to ensure idempotency of requests.

  Optional: 
  - `reason`: the reason for the event being redacted.

  ## Example

      iex> MatrixSDK.Client.Request.redact_room_event("https://matrix.org", "token", "!someroom:matrix.org", "event_id", "transaction_id")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id",
        query_params: []
      }

  With options:

      iex> opt = %{reason: "Indecent material"}
      iex> MatrixSDK.Client.Request.redact_room_event("https://matrix.org", "token", "!someroom:matrix.org", "event_id", "transaction_id", opt)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{reason: "Indecent material"},
        headers: [{"Authorization", "Bearer token"}],
        method: :put,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  Optional: 
  - `visibility`: controls the presence of the room on the room list. One of: `"public"` or `"private"`.
  - `room_alias_name`: the desired room alias local part. 
  - `name`: if this is included, an `m.room.name` event will be sent into the room to indicate the name of the room. 
  - `topic`: if this is included, an `m.room.topic` event will be sent into the room to indicate the topic for the room.
  - `invite`: a list of user IDs to invite to the room.
  - `invite_3pid`: a list of objects representing third party IDs to invite into the room.
  - `room_version`: the room version to set for the room.
  - `creation_content`: extra keys, such as m.federate, to be added to the content of the `m.room.create` event.
  - `initial_state`: a list of state events to set in the new room.
  - `preset`: convenience parameter for setting various default state events based on a preset.
  - `is_direct`: boolean flag. 
  - `power_level_content_override`: the power level content to override in the default power level event. 

  ## Examples

      iex> MatrixSDK.Client.Request.create_room("https://matrix.org", "token")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/createRoom",
        query_params: []
      }

  With options:
      
      iex> opts = %{
      ...>          visibility: "public",
      ...>          room_alias_name: "chocolate",
      ...>          topic: "Some cool stuff about chocolate."
      ...>        }
      iex> MatrixSDK.Client.Request.create_room("https://matrix.org", "token", opts)
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{room_alias_name: "chocolate", topic: "Some cool stuff about chocolate.", visibility: "public"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/createRoom",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Example

        iex> MatrixSDK.Client.Request.joined_rooms("https://matrix.org", "token")
        %MatrixSDK.Client.Request{
          base_url: "https://matrix.org",
          body: %{},
          headers: [{"Authorization", "Bearer token"}],
          method: :get,
          path: "/_matrix/client/r0/joined_rooms",
          query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.
  - `user_id`: the user ID to invite to the room. 

  ## Examples

      iex> MatrixSDK.Client.Request.room_invite("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{user_id: "@user:matrix.org"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/invite",
        query_params: []
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

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id_or_alias`: the room ID or room alias.

  Optional: 
  - `third_party_signed`: a signature of an `m.third_party_invite` token to prove that this user owns a third party identity which has been invited to the room.

  ## Example 

      iex> MatrixSDK.Client.Request.join_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/join/%21someroom%3Amatrix.org",
        query_params: []
      }
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Examples

      iex> MatrixSDK.Client.Request.leave_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/leave",
        query_params: []
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

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Examples

      iex> MatrixSDK.Client.Request.forget_room("https://matrix.org", "token", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/forget",
        query_params: []
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

      iex> MatrixSDK.Client.Request.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/kick",
        body: %{user_id: "@user:matrix.org"}
      }

      iex> MatrixSDK.Client.Request.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/ban",
        body: %{user_id: "@user:matrix.org"}
      }

      iex> MatrixSDK.Client.Request.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.room_unban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.room_visibility("https://matrix.org", "!someroom:matrix.org")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.room_visibility("https://matrix.org", "token", "!someroom:matrix.org", "private")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.public_rooms("https://matrix.org")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/publicRooms",
        query_params: []
      }

  With optional parameters:   

      iex> MatrixSDK.Client.Request.public_rooms("https://matrix.org", %{limit: 10})
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.public_rooms("https://matrix.org", "token", %{limit: 10})
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{limit: 10},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/publicRooms",
        query_params: []
      }

  With optional parameter:

      iex> MatrixSDK.Client.Request.public_rooms("https://matrix.org", "token", %{limit: 10}, "server")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.user_directory_search("https://matrix.org", "token", "mickey")
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{search_term: "mickey"},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/user_directory/search",
      }

  With limit option:

      iex> MatrixSDK.Client.Request.user_directory_search("https://matrix.org", "token", "mickey", %{limit: 42})
      %MatrixSDK.Client.Request{
        base_url: "https://matrix.org",
        body: %{search_term: "mickey", limit: 42},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/user_directory/search",
      }

  With language option:

      iex> MatrixSDK.Client.Request.user_directory_search("https://matrix.org", "token", "mickey", %{language: "en-US"})
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.set_display_name("https://matrix.org", "token", "@user:matrix.org", "mickey")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.display_name("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.set_avatar_url("https://matrix.org", "token", "@user:matrix.org", "mxc://matrix.org/wefh34uihSDRGhw34")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.avatar_url("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
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

      iex> MatrixSDK.Client.Request.user_profile("https://matrix.org", "@user:matrix.org")
      %MatrixSDK.Client.Request{
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
