defmodule MatrixSDK.APITest do
  use ExUnit.Case, async: true
  import Mox

  alias MatrixSDK.{API, HTTPClientMock}
  alias MatrixSDK.API.Request
  alias Tesla

  setup :verify_on_exit!

  describe "do_request/1" do
    test "executes the given request with the configured http client" do
      request = %Request{
        method: :get,
        base_url: "http://test.url",
        path: "/"
      }

      assert_client_mock_got(request)
      API.do_request(request)
    end
  end

  defp assert_client_mock_got(expected_request) do
    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert Map.equal?(request, expected_request)

      {:ok, %Tesla.Env{status: 200}}
    end)
  end
end
