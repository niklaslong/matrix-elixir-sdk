defmodule MatrixSDK.API do
  @moduledoc """
  Provides functions to make HTTP requests to a Matrix homeserver using the
  `MatrixSDK.Request` and `MatrixSDK.HTTPClient` modules.
  """

  alias MatrixSDK.{Request, HTTPClient}

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

  def login(base_url) do
    base_url
    |> Request.login()
    |> @http_client.do_request()
  end

  def login(base_url, username, password) do
    base_url
    |> Request.login(username, password)
    |> @http_client.do_request()
  end

  def logout(base_url, token) do
    base_url
    |> Request.logout(token)
    |> @http_client.do_request()
  end

  def register_user(base_url) do
    base_url
    |> Request.register_user()
    |> @http_client.do_request()
  end

  def register_user(base_url, username, password) do
    base_url
    |> Request.register_user(username, password)
    |> @http_client.do_request()
  end

  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(base_url) do
    base_url
    |> Request.room_discovery()
    |> @http_client.do_request()
  end
end
