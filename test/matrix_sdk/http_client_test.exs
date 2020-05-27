defmodule MatrixSDK.HTTPClientTest do
  use ExUnit.Case

  alias MatrixSDK.HTTPClient
  alias Tesla

  test "client/1 returns Tesla client" do
    url = "http://test.url"
    client = %Tesla.Client{} = HTTPClient.client(url)

    assert client.adapter == {Tesla.Adapter.Mint, :call, [[]]}
    assert client.fun == nil
    assert client.post == []

    assert client.pre == [
             {Tesla.Middleware.BaseUrl, :call, [url]},
             {Tesla.Middleware.Headers, :call, [[{"Accept", "application/json'"}]]},
             {Tesla.Middleware.JSON, :call, [[]]}
           ]
  end

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "request/3:" do
    test "GET", %{bypass: bypass} do
      path = "/test/url"
      client = HTTPClient.client("http://localhost:#{bypass.port}")

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        assert path == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "")
      end)

      HTTPClient.request(:get, client, path)
    end
  end
end
