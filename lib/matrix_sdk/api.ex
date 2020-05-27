defmodule MatrixSDK.API do
  @http_client Application.get_env(:matrix_sdk, :http_client)

  # API Standards

  def spec_versions(client), do: @http_client.request(:get, client, "/_matrix/client/versions")

  # Server discovery

  # NOTE: response headers don't include json => middleware doesn't decode body
  def server_discovery(client),
    do: @http_client.request(:get, client, "/.well-known/matrix/client")

  # User - Login


  # User - registration

  # Rooms

  # TODO: handle chunked responses
  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(client), do: @http_client.request(:get, client, "/_matrix/client/r0/publicRooms")
end
