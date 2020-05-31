defmodule MatrixSDK.API do
  alias MatrixSDK.{Request, HTTPClient}

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

  def login(client), do: @http_client.request(:get, client, "/_matrix/client/r0/login")

  def login(client, username, password) do
    @http_client.request(:post, client, "/_matrix/client/r0/login", %{
      type: "m.login.password",
      user: username,
      password: password
    })
  end

  def logout(client), do: @http_client.request(:post, client, "/_matrix/client/r0/logout")

  def logout(base_url, token) do
    base_url
    |> HTTPClient.client([{"Authorization", "Bearer " <> token}])
    |> logout()
  end

  # User - registration

  def register_user(client, :guest),
    do: @http_client.request(:post, client, "/_matrix/client/r0/register?kind=guest")

  def register_user(client, :user, username, password),
    do:
      @http_client.request(:post, client, "/_matrix/client/r0/register", %{
        auth: %{type: "m.login.dummy"},
        username: username,
        password: password
      })

  # Rooms

  #  TODO: handle chunked responses
  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(client),
    do: @http_client.request(:get, client, "/_matrix/client/r0/publicRooms")
end
