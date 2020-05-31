defmodule MatrixSDK.HTTPClient do
  use Tesla
  alias MatrixSDK.Request

  @callback do_request(Request.t()) :: Tesla.Env.result()

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

  def do_request(%Request{method: :get} = request) do
    request.base_url
    |> client(request.headers)
    |> get(request.path)
  end

  def do_request(%Request{method: :post} = request) do
    request.base_url
    |> client(request.headers)
    |> post(request.path, request.body)
  end

  def request(:get, client, path), do: get(client, path)
  def request(:post, client, path, body \\ %{}), do: post(client, path, body)
end
