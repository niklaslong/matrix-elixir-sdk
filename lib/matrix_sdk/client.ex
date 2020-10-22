defmodule MatrixSDK.Client do
  @moduledoc """
  Provides a wrapper around the `MatrixSDK.HTTPClient` and related configuration. In future it
  will likely abstract response parsing, error handling and configuration. 

  Requests are represented by a `MatrixSDK.Client.Request` struct and executed with a call to
  `MatrixSDK.Client.do_request/1`: 

      "https://matrix.org"
      |> MatrixSDK.Client.Request.login("token")
      |> MatrixSDK.Client.do_request()

  For more information on the currently supported endpoints, see the `MatrixSDK.Client.Request`
  module documentation. 

  ## 3PID API flows

  See this [gist](https://gist.github.com/jryans/839a09bf0c5a70e2f36ed990d50ed928) for more
  details.

  Flow 1—adding a 3PID to HS account during registration: 1. `registration_email_token/5` or
  `registration_msisdn_token/6` 2. `register_user/4`

  Flow 2—adding a 3PID to HS account after registration: 1. `account_email_token/5` or
  `account_msisdn_token/6` 2. `account_add_3pid/5`

  Flow 3—changing the bind status of a 3PID: this is currently unsupported but will be available
  once the identity server endpoints are wrapped.

  Flow 4—reset password via email: 1. `password_email_token/5` 2. `change_password/4`
  """

  alias MatrixSDK.HTTPClient
  alias MatrixSDK.Client.Request

  @doc """
  Executes a given request through the configured HTTP client. 

  ## Examples

      "https://matrix.org"
      |> MatrixSDK.Client.Request.sync("token")
      |> MatrixSDK.Client.do_request(request)
  """
  @spec do_request(Request.t()) :: HTTPClient.result()
  def do_request(request), do: http_client().do_request(request)

  defp http_client(), do: Application.fetch_env!(:matrix_sdk, :http_client)
end
