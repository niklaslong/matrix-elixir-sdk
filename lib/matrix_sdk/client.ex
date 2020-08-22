defmodule MatrixSDK.Client do
  @moduledoc """
  Provides functions to make HTTP requests to a Matrix homeserver using the
  `MatrixSDK.Client.Request` and `MatrixSDK.HTTPClient` modules.

  ## 3PID API flows
  """

  alias MatrixSDK.HTTPClient
  alias MatrixSDK.Client.{Request, Auth, RoomEvent, StateEvent}

  @doc """
  Gets the versions of the Matrix specification supported by the server. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 

  ## Examples

      MatrixSDK.Client.spec_versions("https://matrix.org")
  """
  @spec spec_versions(Request.base_url()) :: HTTPClient.result()
  def spec_versions(base_url) do
    base_url
    |> Request.spec_versions()
    |> http_client().do_request()
  end

  @doc """
  Gets discovery information about the domain. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 

  ## Examples

      MatrixSDK.Client.server_discovery("https://matrix.org")
  """
  @spec server_discovery(Request.base_url()) :: HTTPClient.result()
  def server_discovery(base_url) do
    base_url
    |> Request.server_discovery()
    |> http_client().do_request()
  end

  @doc """
  Gets information about the server's supported feature set and other relevant capabilities.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      MatrixSDK.Client.server_capabilities("https://matrix.org", "token")
  """
  @spec server_capabilities(Request.base_url(), binary) :: HTTPClient.result()
  def server_capabilities(base_url, token) do
    base_url
    |> Request.server_capabilities(token)
    |> http_client().do_request()
  end

  @doc """
  Gets the homeserver's supported login types to authenticate users. 

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver.

  ## Examples

      MatrixSDK.Client.login("https://matrix.org")
  """
  @spec login(Request.base_url()) :: HTTPClient.result()
  def login(base_url) do
    base_url
    |> Request.login()
    |> http_client().do_request()
  end

  @doc """
  Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  Optional:
  - `device_id`: ID of the client device. If this does not correspond to a known client device, a new device will be created. The server will auto-generate a `device_id` if this is not specified.
  - `initial_device_display_name`: a display name to assign to the newly-created device.

  ## Examples

  Token authentication:

      auth = MatrixSDK.Client.Auth.login_token("token")
      MatrixSDK.Client.login("https://matrix.org", auth)

  User and password authentication with optional parameters:

      auth = MatrixSDK.Client.Auth.login_user("maurice_moss", "password")
      opts = %{device_id: "id", initial_device_display_name: "THE INTERNET"}

      MatrixSDK.Client.login("https://matrix.org", auth, opts)
  """
  @spec login(Request.base_url(), Auth.t(), opts :: map) :: HTTPClient.result()
  def login(base_url, auth, opts \\ %{}) do
    base_url
    |> Request.login(auth, opts)
    |> http_client().do_request()
  end

  @doc """
  Invalidates an existing access token, so that it can no longer be used for authorization.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      MatrixSDK.Client.logout("https://matrix.org", "token")
  """
  @spec logout(Request.base_url(), binary) :: HTTPClient.result()
  def logout(base_url, token) do
    base_url
    |> Request.logout(token)
    |> http_client().do_request()
  end

  @doc """
  Invalidates all existing access tokens, so that they can no longer be used for authorization.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      MatrixSDK.Client.logout_all("https://matrix.org", "token")
  """
  @spec logout_all(Request.base_url(), binary) :: HTTPClient.result()
  def logout_all(base_url, token) do
    base_url
    |> Request.logout_all(token)
    |> http_client().do_request()
  end

  @doc """
  Registers a guest account on the homeserver and returns an access token which can be used to authenticate subsequent requests. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 

  Optional: 
  - `initial_device_display_name`: a display name to assign to the newly-created device.

  ## Examples

      MatrixSDK.Client.register_guest("https://matrix.org")

  Specifiying a display name for the device:    

      opts = %{initial_device_display_name: "THE INTERNET"}
      MatrixSDK.Client.register_guest("https://matrix.org", opts)
  """
  @spec register_guest(Request.base_url(), map) :: HTTPClient.result()
  def register_guest(base_url, opts \\ %{}) do
    base_url
    |> Request.register_guest(opts)
    |> http_client().do_request()
  end

  @doc """
  Registers a user account on the homeserver.

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

      MatrixSDK.Client.Request.register_user("https://matrix.org", "password", auth)

  With optional parameters:    
      auth = MatrixSDK.Client.Auth.login_dummy()
      opts = %{
                username: "maurice_moss",
                device_id: "id",
                initial_device_display_name: "THE INTERNET",
                inhibit_login: true
              }

      MatrixSDK.Client.Request.register_user("https://matrix.org", "password", auth, opts)
  """
  @spec register_user(Request.base_url(), binary, Auth.t(), map) :: HTTPClient.result()
  def register_user(base_url, password, auth, opts \\ %{}) do
    base_url
    |> Request.register_user(password, auth, opts)
    |> http_client().do_request()
  end

  @doc """
  Checks the given email address is not already associated with an account on the homeserver. This should be used to get a token to register an email as part of the initial user registration.

  For more info see _3PID API flows_ section above.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `email`: the email address.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL. 

  ## Examples

        MatrixSDK.Client.registration_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
  """
  @spec registration_email_token(Request.base_url(), binary, binary, pos_integer, map) ::
          HTTPClient.result()
  def registration_email_token(base_url, client_secret, email, send_attempt, opts \\ %{}) do
    base_url
    |> Request.registration_email_token(client_secret, email, send_attempt, opts)
    |> http_client().do_request()
  end

  @doc """
  Checks the given phone number is not already associated with an account on the homeserver. This should be used to get a token to register a phone number as part of the initial user registration.

  For more info see _3PID API flows_ section above.

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

        MatrixSDK.Client.registration_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
  """
  @spec registration_msisdn_token(Request.base_url(), binary, binary, binary, pos_integer, map) ::
          HTTPClient.result()
  def registration_msisdn_token(
        base_url,
        client_secret,
        country,
        phone,
        send_attempt,
        opts \\ %{}
      ) do
    base_url
    |> Request.registration_msisdn_token(client_secret, country, phone, send_attempt, opts)
    |> http_client().do_request()
  end

  @doc """
  Checks if a username is available and valid for the server.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `username`: the basis for the localpart of the desired Matrix ID.

  ## Examples

       MatrixSDK.Client.username_availability("https://matrix.org", "maurice_moss")
  """
  @spec username_availability(Request.base_url(), binary) :: HTTPClient.result()
  def username_availability(base_url, username) do
    base_url
    |> Request.username_availability(username)
    |> http_client().do_request()
  end

  @doc """
  Changes the password for an account on the homeserver. This request will need to be authenticated with `m.login.email.identity` or `m.login.msisdn.identity`. For more info see _3PID API flows_ section above. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver.   
  - `new_password`: the desired password for the account.
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  Optional: 
  - `logout_devices`: `true` or `false`, whether the user's other access tokens, and their associated devices, should be revoked if the request succeeds.

  ## Examples 
      
      auth = MatrixSDK.Client.Auth.login_email_identity("sid", "client_secret")
      MatrixSDK.Client.Request.change_password("https://matrix.org", "new_password", auth)
  """
  @spec change_password(Request.base_url(), binary, Auth.t(), map) :: HTTPClient.result()
  def change_password(base_url, new_password, auth, opts \\ %{}) do
    base_url
    |> Request.change_password(new_password, auth, opts)
    |> http_client().do_request()
  end

  @doc """
  Request validation tokens when authenticating for `change_password/4`. 

  For more info see _3PID API flows_ section above. 

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `client_secret`: a unique string generated by the client, and used to identify the validation attempt. It must be a string consisting of the characters `[0-9a-zA-Z.=_-]`. Its length must not exceed 255 characters and it must not be empty.
  - `email`: the email address.
  - `send_attempt`: stops the server from sending duplicate emails unless incremented by the client. 

  Optional:
  - `next_link`: when the validation is completed, the identity server will redirect the user to this URL.

  ## Examples

      MatrixSDK.Client.password_email_token("https://matrix.org", "secret", "maurice@moss.yay", 1)
  """
  @spec password_email_token(Request.base_url(), binary, binary, pos_integer, map) ::
          HTTPClient.result()
  def password_email_token(base_url, client_secret, email, send_attempt, opts \\ %{}) do
    base_url
    |> Request.password_email_token(client_secret, email, send_attempt, opts)
    |> http_client().do_request()
  end

  @doc """
  Request validation tokens when authenticating for `change_password/4`.

  For more info see _3PID API flows_ section above. 

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

      MatrixSDK.Client.password_msisdn_token("https://matrix.org", "secret", "GB", "07700900001", 1)
  """
  @spec password_msisdn_token(Request.base_url(), binary, binary, binary, pos_integer, map) ::
          HTTPClient.result()
  def password_msisdn_token(base_url, client_secret, country, phone, send_attempt, opts \\ %{}) do
    base_url
    |> Request.password_msisdn_token(client_secret, country, phone, send_attempt, opts)
    |> http_client().do_request()
  end

  @doc """
  Deactivates a user's account. 

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  Optional: 
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  ## Examples

      MatrixSDK.Client.deactivate_account("https://matrix.org", "token")
  """
  @spec deactivate_account(Request.base_url(), binary, map) :: HTTPClient.result()
  def deactivate_account(base_url, token, opts \\ %{}) do
    base_url
    |> Request.deactivate_account(token, opts)
    |> http_client().do_request()
  end

  @doc """
  Gets a list of the third party identifiers the homeserver has associated with the user's account.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      MatrixSDK.Client.account_3pids("https://matrix.org", "token")
  """
  @spec account_3pids(Request.base_url(), binary) :: HTTPClient.result()
  def account_3pids(base_url, token) do
    base_url
    |> Request.account_3pids(token)
    |> http_client().do_request()
  end

  @doc """
  Adds contact information to the user's account.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: the client secret used in the session with the homeserver.
  - `sid`: the session ID give by the homeserver. 

  Optional:
  - `auth`: a map containing autentication data as defined by `MatrixSDK.Client.Auth`.

  For more info see _3PID API flows_ section above.

  ## Examples

      MatrixSDK.Client.account_add_3pid("https://matrix.org", "token", "client_secret", "sid")
  """
  @spec account_add_3pid(Request.base_url(), binary, binary, binary, map) ::
          HTTPClient.result()
  def account_add_3pid(base_url, token, client_secret, sid, opts \\ %{}) do
    base_url
    |> Request.account_add_3pid(token, client_secret, sid, opts)
    |> http_client().do_request()
  end

  @doc """
  Binds contact information to the user's account through the specified identity server.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `client_secret`: the client secret used in the session with the identity server.
  - `id_server`: the identity server to use.
  - `id_access_token`: an access token previously registered with the identity server.
  - `sid`: he session ID given by the identity server.

  For more info see _3PID API flows_ section above.

  ## Examples

      MatrixSDK.Client.account_bind_3pid("https://matrix.org", "token", "client_secret", "example.org", "abc123", "sid")
  """
  @spec account_bind_3pid(Request.base_url(), binary, binary, binary, binary, binary) ::
          HTTPClient.result()
  def account_bind_3pid(base_url, token, client_secret, id_server, id_access_token, sid) do
    base_url
    |> Request.account_bind_3pid(token, client_secret, id_server, id_access_token, sid)
    |> http_client().do_request()
  end

  @doc """
  Deletes contact information from the user's account.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `medium`: the medium of the third party identifier being removed. One of: `"email"` or `"msisdn"`.
  - `address`: the third party address being removed.

  Optional: 

  - `id_server`: the identity server to unbind from.

  ## Examples

      MatrixSDK.Client.account_delete_3pid("https://matrix.org", "token", "email", "example@example.org")

  With `id_server` option:

      MatrixSDK.Client.account_delete_3pid("https://matrix.org", "token", "email", "example@example.org", %{id_server: "id.example.org")
  """
  @spec account_delete_3pid(Request.base_url(), binary, binary, binary, map) ::
          HTTPClient.result()
  def account_delete_3pid(base_url, token, medium, address, opt \\ %{}) do
    base_url
    |> Request.account_delete_3pid(token, medium, address, opt)
    |> http_client().do_request()
  end

  @doc """
  Unbinds contact information from the user's account without deleting it from the homeserver.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `medium`: the medium of the third party identifier being removed. One of: `"email"` or `"msisdn"`.
  - `address`: the third party address being removed. 

  Optional:
  - `id_server`: the identity server to unbind from.

  ## Examples

      MatrixSDK.Client.account_unbind_3pid("https://matrix.org", "token", "email", "example@example.org")

  With `id_server` option:

      MatrixSDK.Client.account_unbind_3pid("https://matrix.org", "token", "email", "example@example.org", %{id_server: "id.example.org"})
  """
  @spec account_unbind_3pid(Request.base_url(), binary, binary, binary, map) ::
          HTTPClient.result()
  def account_unbind_3pid(base_url, token, medium, address, opt \\ %{}) do
    base_url
    |> Request.account_unbind_3pid(token, medium, address, opt)
    |> http_client().do_request()
  end

  @doc """
  Requests a validation token when adding an email to a user's account.

  For more info see _3PID API flows_ section above. 

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

      MatrixSDK.Client.account_email_token("https://matrix.org", "token", "client_secret", "example@example.org", 1)

  With optional parameter:

      opt = %{next_link: "test-site.url"}
      MatrixSDK.Client.account_email_token("https://matrix.org", "token", "client_secret", "example@example.org", 1, opts)
  """
  @spec account_email_token(
          Request.base_url(),
          binary,
          binary,
          binary,
          pos_integer,
          map
        ) :: HTTPClient.result()
  def account_email_token(
        base_url,
        token,
        client_secret,
        email,
        send_attempt,
        opts \\ %{}
      ) do
    base_url
    |> Request.account_email_token(token, client_secret, email, send_attempt, opts)
    |> http_client().do_request()
  end

  @doc """
  Requests a validation token when adding a phone number to a user's account.

  For more info see _3PID API flows_ section above.

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

      MatrixSDK.Client.account_msisdn_token("https://matrix.org", "token", "client_secret", "GB", "07700900001", 1)

  With optional paramter:

      opt = %{next_link: "test-site.url"}
      MatrixSDK.Client.account_msisdn_token("https://matrix.org", "token", "client_secret", "GB", "07700900001", 1, opt)
  """
  @spec account_msisdn_token(
          Request.base_url(),
          binary,
          binary,
          binary,
          binary,
          pos_integer,
          map
        ) :: HTTPClient.result()
  def account_msisdn_token(
        base_url,
        token,
        client_secret,
        country,
        phone,
        send_attempt,
        opts \\ %{}
      ) do
    base_url
    |> Request.account_msisdn_token(
      token,
      client_secret,
      country,
      phone,
      send_attempt,
      opts
    )
    |> http_client().do_request()
  end

  @doc """
  Gets information about the owner of a given access token.

  ## Args

  Required: 

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Examples

      MatrixSDK.Client.whoami("https://matrix.org", "token")
  """
  @spec whoami(Request.base_url(), binary) :: HTTPClient.result()
  def whoami(base_url, token) do
    base_url
    |> Request.whoami(token)
    |> http_client().do_request()
  end

  @doc """
  Synchronises the client's state with the latest state on the server.

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
      
      MatrixSDK.Client.sync("https://matrix.org", "token")

  With optional parameters:

      opts = %{
                since: "s123456789",
                filter: "filter",
                full_state: true,
                set_presence: "online",
                timeout: 1000
              }

      MatrixSDK.Client.sync("https://matrix.org", "token", opts)
  """
  @spec sync(Request.base_url(), binary, map) :: HTTPClient.result()
  def sync(base_url, token, opts \\ %{}) do
    base_url
    |> Request.sync(token, opts)
    |> http_client().do_request()
  end

  @doc """
  Gets a single event based on `room_id` and `event_id`.

  ## Args

  Required:

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the ID of the room the event is in. 
  - `event_id`: the event ID.

  ## Example

      MatrixSDK.Client.room_event("https://matrix.org", "token", "!someroom:matrix.org", "$someevent")
  """
  @spec room_event(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def room_event(base_url, token, room_id, event_id) do
    base_url
    |> Request.room_event(token, room_id, event_id)
    |> http_client().do_request()
  end

  @doc """
  Looks up the contents of a state event in a room.

  ## Args

  Required:

  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room the state event is in.
  - `event_type`: the type of the state event.
  - `state_key`: the key of the state to look up. Often an empty string.

  ## Example

      MatrixSDK.Client.room_state_event("https://matrix.org", "token", "!someroom:matrix.org", "m.room.member", "@user:matrix.org") 
  """
  @spec room_state_event(Request.base_url(), binary, binary, binary, binary) ::
          HTTPClient.result()
  def room_state_event(base_url, token, room_id, event_type, state_key) do
    base_url
    |> Request.room_state_event(token, room_id, event_type, state_key)
    |> http_client().do_request()
  end

  @doc """
  Gets the state events for the current state of a room.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room the events are in. 

  ## Example 


      MatrixSDK.Client.room_state("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec room_state(Request.base_url(), binary, binary) :: HTTPClient.result()
  def room_state(base_url, token, room_id) do
    base_url
    |> Request.room_state(token, room_id)
    |> http_client().do_request()
  end

  @doc """
  Gets the list of members for this room.

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

      MatrixSDK.Client.room_members("https://matrix.org", "token", "!someroom:matrix.org")

  With optional parameters:

      opts = %{
                at: "t123456789",
                membership: "join",
                not_membership: "invite"
              }

      MatrixSDK.Client.room_members("https://matrix.org", "token", "!someroom:matrix.org", opts)
  """
  @spec room_members(Request.base_url(), binary, binary, map) :: HTTPClient.result()
  def room_members(base_url, token, room_id, opts \\ %{}) do
    base_url
    |> Request.room_members(token, room_id, opts)
    |> http_client().do_request()
  end

  @doc """
  Gets a map of MXIDs to member info objects for members of the room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Example 

      MatrixSDK.Client.room_joined_members("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec room_joined_members(Request.base_url(), binary, binary) :: HTTPClient.result()
  def room_joined_members(base_url, token, room_id) do
    base_url
    |> Request.room_joined_members(token, room_id)
    |> http_client().do_request()
  end

  @doc """
  Gets message and state events for a room. 
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

      MatrixSDK.Client.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f")

  With optional parameters:

      opts = %{
                to: "t123456789",
                limit: 10,
                filter: "filter"
              }

      MatrixSDK.Client.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f", opts)
  """
  @spec room_messages(Request.base_url(), binary, binary, binary, binary, map) ::
          HTTPClient.result()
  def room_messages(base_url, token, room_id, from, dir, opts \\ %{}) do
    base_url
    |> Request.room_messages(token, room_id, from, dir, opts)
    |> http_client().do_request()
  end

  @doc """
  Sends a state event to a room. 

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `state_event`: a state event as defined in `MatrixSDK.Client.StateEvent`.

  ## Example

      state_event = MatrixSDK.Client.StateEvent.join_rules("!someroom:matrix.org", "private")
      MatrixSDK.Client.Request.send_state_event("https://matrix.org", "token", state_event)
  """
  @spec send_state_event(Request.base_url(), binary, StateEvent.t()) :: HTTPClient.result()
  def send_state_event(base_url, token, state_event) do
    base_url
    |> Request.send_state_event(token, state_event)
    |> http_client().do_request()
  end

  @doc """
  Sends a room event to a room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_event`: a state event as defined in `MatrixSDK.Client.RoomEvent`. 

  ## Example

      room_event = MatrixSDK.Client.RoomEvent.message("!someroom:matrix.org", :text, "Fire! Fire! Fire!", "transaction_id")
      MatrixSDK.Client.Request.send_room_event("https://matrix.org", "token", room_event)
  """
  @spec send_room_event(Request.base_url(), binary, RoomEvent.t()) :: HTTPClient.result()
  def send_room_event(base_url, token, room_event) do
    base_url
    |> Request.send_room_event(token, room_event)
    |> http_client().do_request()
  end

  @doc """
  Redacts a room event with a reason.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID. 
  - `event_id`: the event ID.
  - `transaction_id`: the transaction ID for this event. Clients should generate a unique ID; it will be used by the server to ensure idempotency of requests.

  Optional: 
  - `reason`: the reason for the event being redacted.

  ## Examples

      MatrixSDK.Client.redact_room_event("https://matrix.org", "token", "!someroom@matrix.org", "event_id", "transaction_id")

  With reason option:

      opt = %{reason: "Indecent material"}

      MatrixSDK.Client.redact_room_event("https://matrix.org", "token", "!someroom@matrix.org", "event_id", "transaction_id", opt)
  """
  @spec redact_room_event(Request.base_url(), binary, binary, binary, binary, map) ::
          HTTPClient.result()
  def redact_room_event(base_url, token, room_id, event_id, transaction_id, opt \\ %{}) do
    base_url
    |> Request.redact_room_event(token, room_id, event_id, transaction_id, opt)
    |> http_client().do_request()
  end

  @doc """
  Creates a new room. 

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

      MatrixSDK.Client.create_room("https://matrix.org", "token")

  With options:

      opts = %{
        visibility: "public",
        room_alias_name: "chocolate",
        topic: "Some cool stuff about chocolate."
      }
      
      MatrixSDK.Client.create_room("https://matrix.org", "token", opts)
  """
  @spec create_room(Request.base_url(), binary, map) :: HTTPClient.result()
  def create_room(base_url, token, opts \\ %{}) do
    base_url
    |> Request.create_room(token, opts)
    |> http_client().do_request()
  end

  @doc """
  Gets a list of the user's current rooms.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.

  ## Example

      MatrixSDK.Client.joined_rooms("https://matrix.org", "token")
  """
  @spec joined_rooms(Request.base_url(), binary) :: HTTPClient.result()
  def joined_rooms(base_url, token) do
    base_url
    |> Request.joined_rooms(token)
    |> http_client().do_request()
  end

  @doc """
  Invites a user to participate in a particular room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.
  - `user_id`: the user ID to invite to the room.

  ## Example

      MatrixSDK.Client.room_invite("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
  """
  @spec room_invite(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def room_invite(base_url, token, room_id, user_id) do
    base_url
    |> Request.room_invite(token, room_id, user_id)
    |> http_client().do_request()
  end

  @doc """
  Lets a user join a room.

  ## Args

  Required:
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id_or_alias`: the room ID or room alias.

  Optional: 
  - `third_party_signed`: a signature of an `m.third_party_invite` token to prove that this user owns a third party identity which has been invited to the room.

  ## Example 

      MatrixSDK.Client.join_room("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec join_room(Request.base_url(), binary, binary, map) :: HTTPClient.result()
  def join_room(base_url, token, room_id_or_alias, opts \\ %{}) do
    base_url
    |> Request.join_room(token, room_id_or_alias, opts)
    |> http_client().do_request()
  end

  @doc """
  Lets a user leave a room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Example 

      MatrixSDK.Client.leave_room("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec leave_room(Request.base_url(), binary, binary) :: HTTPClient.result()
  def leave_room(base_url, token, room_id) do
    base_url
    |> Request.leave_room(token, room_id)
    |> http_client().do_request()
  end

  @doc """
  Lets a user forget a room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.

  ## Example 

      MatrixSDK.Client.forget_room("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec forget_room(Request.base_url(), binary, binary) :: HTTPClient.result()
  def forget_room(base_url, token, room_id) do
    base_url
    |> Request.forget_room(token, room_id)
    |> http_client().do_request()
  end

  @doc """
  Kicks a user from a room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.
  - `user_id`: the user ID to kick from the room.

  Optional: 
  - `reason`: the reason the user has been kicked.

  ## Examples

      MatrixSDK.Client.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")

  With option: 

      MatrixSDK.Client.room_kick("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
  """
  @spec room_kick(Request.base_url(), binary, binary, binary, map) :: HTTPClient.result()
  def room_kick(base_url, token, room_id, user_id, opt \\ %{}) do
    base_url
    |> Request.room_kick(token, room_id, user_id, opt)
    |> http_client().do_request()
  end

  @doc """
  Bans a user from a room.

  ## Args

  Required: 
  - `base_url`: the base URL for the homeserver. 
  - `token`: access token, typically obtained via the login or registration processes.
  - `room_id`: the room ID.
  - `user_id`: the user ID to ban from the room.

  Optional: 
  - `reason`: the reason the user has been banned.

  ## Examples

      MatrixSDK.Client.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")

  With option: 

      MatrixSDK.Client.room_ban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org", %{reason: "Ate all the chocolate"})
  """
  @spec room_ban(Request.base_url(), binary, binary, binary, map) :: HTTPClient.result()
  def room_ban(base_url, token, room_id, user_id, opt \\ %{}) do
    base_url
    |> Request.room_ban(token, room_id, user_id, opt)
    |> http_client().do_request()
  end

  @doc """
  Unbans a user from a room.

  ## Examples

      MatrixSDK.Client.room_unban("https://matrix.org", "token", "!someroom:matrix.org", "@user:matrix.org")
  """
  @spec room_unban(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def room_unban(base_url, token, room_id, user_id) do
    base_url
    |> Request.room_unban(token, room_id, user_id)
    |> http_client().do_request()
  end

  @doc """
  Gets the visibility of a given room on the server's public room directory.

  ## Example

      MatrixSDK.Client.room_visibility("https://matrix.org", "!someroom:matrix.org")
  """
  @spec room_visibility(Request.base_url(), binary) :: HTTPClient.result()
  def room_visibility(base_url, room_id) do
    base_url
    |> Request.room_visibility(room_id)
    |> http_client().do_request()
  end

  @doc """
  Sets the visibility of a given room in the server's public room directory.

  ## Example

      MatrixSDK.Client.room_visibility("https://matrix.org", "token", "!someroom:matrix.org", "private")
  """
  @spec room_visibility(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def room_visibility(base_url, token, room_id, visibility) do
    base_url
    |> Request.room_visibility(token, room_id, visibility)
    |> http_client().do_request()
  end

  @doc """
  Lists the public rooms on the server with basic filtering.

  ## Examples

      MatrixSDK.Client.public_rooms("https://matrix.org")

  With optional parameters:   

      MatrixSDK.Client.public_rooms("https://matrix.org", %{limit: 10})
  """
  @spec public_rooms(Request.base_url(), map) :: HTTPClient.result()
  def public_rooms(base_url, opts \\ %{}) do
    base_url
    |> Request.public_rooms(opts)
    |> http_client().do_request()
  end

  @doc """
  Lists the public rooms on the server with more advanced filtering options. 

  ## Examples

      MatrixSDK.Client.public_rooms("https://matrix.org", "token", %{limit: 10})

  With optional parameter:

      MatrixSDK.Client.public_rooms("https://matrix.org", "token", %{limit: 10}, "server")
  """
  @spec public_rooms(Request.base_url(), binary, map, binary) :: HTTPClient.result()
  def public_rooms(base_url, token, filter, server \\ nil) do
    base_url
    |> Request.public_rooms(token, filter, server)
    |> http_client().do_request()
  end

  @doc """
  Searches for users based on search term.

  ## Examples

      MatrixSDK.Client.user_directory_search("https://matrix.org", "token", "mickey")

  With options:

      MatrixSDK.Client.user_directory_search("https://matrix.org", "token", %{limit: 10, language: "en-US"})
  """
  @spec user_directory_search(Request.base_url(), binary, binary, map) :: HTTPClient.result()
  def user_directory_search(base_url, token, search_term, opts \\ %{}) do
    base_url
    |> Request.user_directory_search(token, search_term, opts)
    |> http_client().do_request()
  end

  @doc """
  Sets the display name for a user.

  ## Examples

      MatrixSDK.Client.set_display_name("https://matrix.org", "token", "@user:matrix.org", "mickey")
  """
  @spec set_display_name(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def set_display_name(base_url, token, user_id, display_name) do
    base_url
    |> Request.set_display_name(token, user_id, display_name)
    |> http_client().do_request()
  end

  @doc """
  Retrieves the display name for a user.

  ## Examples

      MatrixSDK.Client.display_name("https://matrix.org", "@user:matrix.org")
  """
  @spec display_name(Request.base_url(), binary) :: HTTPClient.result()
  def display_name(base_url, user_id) do
    base_url
    |> Request.display_name(user_id)
    |> http_client().do_request()
  end

  @doc """
  Sets the avatar url for a user.

  ## Examples

      MatrixSDK.Client.set_avatar_url("https://matrix.org", "token", "@user:matrix.org", "mxc://matrix.org/wefh34uihSDRGhw34")
  """
  @spec set_avatar_url(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def set_avatar_url(base_url, token, user_id, avatar_url) do
    base_url
    |> Request.set_avatar_url(token, user_id, avatar_url)
    |> http_client().do_request()
  end

  @doc """
  Retrieves the avatar url for a user.

  ## Examples

      MatrixSDK.Client.avatar_url("https://matrix.org", "@user:matrix.org")
  """
  @spec avatar_url(Request.base_url(), binary) :: HTTPClient.result()
  def avatar_url(base_url, user_id) do
    base_url
    |> Request.avatar_url(user_id)
    |> http_client().do_request()
  end

  @doc """
  Retrieves the user profile for a user.

  ## Examples

      MatrixSDK.Client.user_profile("https://matrix.org", "@user:matrix.org")
  """
  @spec user_profile(Request.base_url(), binary) :: HTTPClient.result()
  def user_profile(base_url, user_id) do
    base_url
    |> Request.user_profile(user_id)
    |> http_client().do_request()
  end

  defp http_client(), do: Application.fetch_env!(:matrix_sdk, :http_client)
end
