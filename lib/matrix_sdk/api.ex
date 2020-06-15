defmodule MatrixSDK.API do
  @moduledoc """
  Provides functions to make HTTP requests to a Matrix homeserver using the
  `MatrixSDK.Request` and `MatrixSDK.HTTPClient` modules.
  """

  alias MatrixSDK.{Request, HTTPClient, Auth}

  @http_client Application.get_env(:matrix_sdk, :http_client)

  @doc """
  Gets the versions of the Matrix specification supported by the server.  

  ## Examples

      MatrixSDK.API.spec_versions("https://matrix.org")
  """
  @spec spec_versions(Request.base_url()) :: HTTPClient.result()
  def spec_versions(base_url) do
    base_url
    |> Request.spec_versions()
    |> @http_client.do_request()
  end

  @doc """
  Gets discovery information about the domain. 

  ## Examples

      MatrixSDK.API.server_discovery("https://matrix.org")
  """
  @spec server_discovery(Request.base_url()) :: HTTPClient.result()
  def server_discovery(base_url) do
    base_url
    |> Request.server_discovery()
    |> @http_client.do_request()
  end

  @doc """
  Gets information about the server's supported feature set and other relevant capabilities.

  ## Examples

      MatrixSDK.API.server_capabilities("https://matrix.org", "token")
  """
  @spec server_capabilities(Request.base_url(), binary) :: HTTPClient.result()
  def server_capabilities(base_url, token) do
    base_url
    |> Request.server_capabilities(token)
    |> @http_client.do_request()
  end

  @doc """
  Gets the homeserver's supported login types to authenticate users. 

  ## Examples

      MatrixSDK.API.login("https://matrix.org")
  """
  @spec login(Request.base_url()) :: HTTPClient.result()
  def login(base_url) do
    base_url
    |> Request.login()
    |> @http_client.do_request()
  end

  @doc """
  Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.

  ## Examples

  Token authentication:

      auth = MatrixSDK.Auth.login_token("token")
      MatrixSDK.API.login("https://matrix.org", auth)

  User and password authentication with optional parameters:

      auth = MatrixSDK.Auth.login_user("maurice_moss", "password")
      opts = %{device_id: "id", initial_device_display_name: "THE INTERNET"}

      MatrixSDK.API.login("https://matrix.org", auth, opts)
  """
  @spec login(Request.base_url(), Auth.t(), opts :: map) :: HTTPClient.result()
  def login(base_url, auth, opts \\ %{}) do
    base_url
    |> Request.login(auth, opts)
    |> @http_client.do_request()
  end

  @doc """
  Invalidates an existing access token, so that it can no longer be used for authorization.

  ## Examples

      MatrixSDK.API.logout("https://matrix.org", "token")
  """
  @spec logout(Request.base_url(), binary) :: HTTPClient.result()
  def logout(base_url, token) do
    base_url
    |> Request.logout(token)
    |> @http_client.do_request()
  end

  @doc """
  Invalidates all existing access tokens, so that they can no longer be used for authorization.

  ## Examples

      MatrixSDK.API.logout_all("https://matrix.org", "token")
  """
  @spec logout_all(Request.base_url(), binary) :: HTTPClient.result()
  def logout_all(base_url, token) do
    base_url
    |> Request.logout_all(token)
    |> @http_client.do_request()
  end

  @doc """
  Registers a guest account on the homeserver. 

  ## Examples

      MatrixSDK.API.register_guest("https://matrix.org")

  Specifiying a display name for the device:    

      opts = %{initial_device_display_name: "THE INTERNET"}
      MatrixSDK.API.register_guest("https://matrix.org", opts)
  """
  @spec register_guest(Request.base_url(), map) :: HTTPClient.result()
  def register_guest(base_url, opts \\ %{}) do
    base_url
    |> Request.register_guest(opts)
    |> @http_client.do_request()
  end

  @doc """
  Registers a user account on the homeserver. 

  ## Examples

      MatrixSDK.API.register_user("https://matrix.org", "password")

  With optional parameters:    

      opts = %{
                username: "maurice_moss",
                device_id: "id",
                initial_device_display_name: "THE INTERNET",
                inhibit_login: true
              }

      MatrixSDK.API.register_user("https://matrix.org", "password", opts)
  """
  @spec register_user(Request.base_url(), binary, map) :: HTTPClient.result()
  def register_user(base_url, password, opts \\ %{}) do
    base_url
    |> Request.register_user(password, opts)
    |> @http_client.do_request()
  end

  @doc """
  Checks if a username is available and valid for the server.

  ## Examples

       MatrixSDK.API.username_availability("https://matrix.org", "maurice_moss")
  """
  @spec username_availability(Request.base_url(), binary) :: HTTPClient.result()
  def username_availability(base_url, username) do
    base_url
    |> Request.username_availability(username)
    |> @http_client.do_request()
  end

  @doc """
  Changes the password for an account on the homeserver.

  ## Examples 

      auth = MatrixSDK.Auth.login_token("token")
      MatrixSDK.API.change_password("https://matrix.org", "new_password", auth)
  """
  @spec change_password(Request.base_url(), binary, Auth.t(), map) :: HTTPClient.result()
  # REVIEW: This requires m.login.email.identity 
  def change_password(base_url, new_password, auth, opts \\ %{}) do
    base_url
    |> Request.change_password(new_password, auth, opts)
    |> @http_client.do_request()
  end

  @doc """
  Gets a list of the third party identifiers the homeserver has associated with the user's account.

  ## Examples

      MatrixSDK.API.account_3pids("https://matrix.org", "token")
  """
  @spec account_3pids(Request.base_url(), binary) :: HTTPClient.result()
  def account_3pids(base_url, token) do
    base_url
    |> Request.account_3pids(token)
    |> @http_client.do_request()
  end

  @doc """
  Gets information about the owner of a given access token.

  ## Examples

      MatrixSDK.API.whoami("https://matrix.org", "token")
  """
  @spec whoami(Request.base_url(), binary) :: HTTPClient.result()
  def whoami(base_url, token) do
    base_url
    |> Request.whoami(token)
    |> @http_client.do_request()
  end

  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(base_url) do
    base_url
    |> Request.room_discovery()
    |> @http_client.do_request()
  end
end
