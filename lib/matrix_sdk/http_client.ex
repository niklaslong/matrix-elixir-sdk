defmodule MatrixSDK.HTTPClient do
  @moduledoc """
  Provides functions to makes HTTP requests using `Tesla`.
  """

  use Tesla, docs: false
  alias MatrixSDK.API.Request

  @type result :: Tesla.Env.result()

  @callback do_request(Request.t()) :: Tesla.Env.result()

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
    |> get(request.path, query: request.query_params)
  end

  def do_request(%Request{method: :post} = request) do
    request.base_url
    |> client(request.headers)
    |> post(request.path, request.body, query: request.query_params)
  end

  def do_request(%Request{method: :put} = request) do
    request.base_url
    |> client(request.headers)
    |> put(request.path, request.body, query: request.query_params)
  end

  def do_request(%Request{method: :delete} = request) do
    request.base_url
    |> client(request.headers)
    |> delete(request.path, query: request.query_params)
  end
end
