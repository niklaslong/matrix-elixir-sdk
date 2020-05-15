defmodule MatrixSDK.APITest do
  use ExUnit.Case
  import Mox

  alias MatrixSDK.{API, HTTPClient, HTTPClientMock}
  alias Tesla

  setup :verify_on_exit!

  test "spec_versions/1: returns supported matrix spec" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :get, ^client, "/_matrix/client/versions" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.spec_versions(client)
  end
end
