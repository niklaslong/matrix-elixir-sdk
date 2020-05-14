defmodule Neobeam.Api do
  use Tesla

  def spec_versions() do
    get(client(), "/_matrix/client/versions")
  end 

  # TODO: response headers don't include json => middleware doesn't decode body
  def server_discovery() do
    get(client(), "/.well-known/matrix/client")
  end

  defp client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://matrix.org"},
      {Tesla.Middleware.Headers, [{"Accept", "application/json'"}]},
      Tesla.Middleware.JSON
    ]
    
    Tesla.client(middleware)
  end
end
