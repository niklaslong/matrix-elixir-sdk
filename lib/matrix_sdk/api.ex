defmodule MatrixSDK.API do
  alias MatrixSDK.{Request}

  @http_client Application.get_env(:matrix_sdk, :http_client)

  #  API Standards

  def spec_versions(base_url) do
    base_url
    |> Request.spec_versions()
    |> @http_client.do_request()
  end

  # Server discovery

  # NOTE: response headers don't include json => middleware doesn't decode body
  def server_discovery(base_url) do
    base_url
    |> Request.server_discovery()
    |> @http_client.do_request()
  end

  # User - login/logout

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

  # User - registration

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

  # Rooms

  #  TODO: handle chunked responses
  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(client),
    do: @http_client.request(:get, client, "/_matrix/client/r0/publicRooms")
end
