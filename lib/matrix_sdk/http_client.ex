defmodule MatrixSDK.HTTPClient do
  use Tesla

  @callback request(atom, Tesla.Env.client(), Tesla.Env.url()) :: Tesla.Env.result()

  def client(base_url) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, [{"Accept", "application/json'"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def request(:get, client, path), do: get(client, path)
end
