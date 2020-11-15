defmodule MatrixSDK.HTTPClient do
  @moduledoc """
  Provides functions to makes HTTP requests using `Tesla`.
  """

  use Tesla, docs: false
  alias MatrixSDK.API.{Request, Error}

  # TODO: for the HTTP client to be configurable the return type needs to be
  # more generic. Maybe we should require the HTTPClient to return
  # `API.Response | API.Error | Tesla.Env.result()`?
  @type result :: Tesla.Env.result()

  @callback do_request(Request.t()) :: Tesla.Env.result() | Error.t()

  #  TODO: could be private?
  def client(base_url, headers \\ []) do
    headers = [{"Accept", "application/json'"} | headers]

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, headers},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, Tesla.Adapter.Mint)
  end

  def do_request(%Request{} = request) do
    with client <- client(request.base_url, request.headers),
         {:ok, response} <- do_request(client, request),
         result <- parse(response) do
      result
    else
      #  Will currently only match on Tesla errors.
      error -> error
    end
  end

  defp do_request(client, request) do
    case request.method do
      :get -> get(client, request.path, query: request.query_params)
      :post -> post(client, request.path, request.body, query: request.query_params)
      :put -> put(client, request.path, request.body, query: request.query_params)
      :delete -> delete(client, request.path, query: request.query_params)
    end
  end

  # Delegates to the appropriate parser based on the status code.
  # TODO: introduce successful response parsing and determine what status codes
  # correspond to error/success.
  defp parse(response) do
    response.status
    |> Integer.digits()
    |> List.first()
    |> case do
      4 -> Error.for(response)
      # In future we may want to specifically parse 2xx.
      _ -> response
    end
  end
end
