defmodule MatrixSDK.HTTPClient do
  use Tesla
  alias MatrixSDK.Request

  @callback request(atom, Tesla.Env.client(), Tesla.Env.url()) :: Tesla.Env.result()
  @callback request(atom, Tesla.Env.client(), Tesla.Env.url(), term()) :: Tesla.Env.result()

  def client(base_url, headers \\ []) do
    headers = [{"Accept", "application/json'"} | headers]

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, headers},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, Tesla.Adapter.Mint)
  end

  def do_request(%Request{method: :get, path: path, headers: headers}, base_url) do
    base_url
    |> client(headers)
    |> get(path)
  end

  def do_request(%Request{method: :post, path: path, headers: headers, body: body}, base_url) do
    base_url
    |> client(headers)
    |> post(path, body)
  end

  def request(:get, client, path), do: get(client, path)
  def request(:post, client, path, body \\ %{}), do: post(client, path, body)
end
