defmodule MatrixSDK.ClientTest do
  use ExUnit.Case, async: true
  import Mox

  alias MatrixSDK.{Client, HTTPClientMock}
  alias MatrixSDK.Client.Request
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
      Client.do_request(request)
    end
  end

  defp assert_client_mock_got(expected_request) do
    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert Map.equal?(request, expected_request)

      {:ok, %Tesla.Env{}}
    end)
  end
end
