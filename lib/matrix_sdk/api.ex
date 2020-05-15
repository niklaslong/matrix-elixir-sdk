defmodule MatrixSDK.API do
  @http_client Application.get_env(:matrix_sdk, :http_client)

  def spec_versions(client), do: @http_client.request(:get, client, "/_matrix/client/versions")

  # TODO: response headers don't include json => middleware doesn't decode body
  def server_discovery(client),
    do: @http_client.request(:get, client, "/.well-known/matrix/client")
end
