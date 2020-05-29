defmodule MatrixSDK.HTTPClientTest do
  use ExUnit.Case

  alias MatrixSDK.HTTPClient
  alias Tesla

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

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

  test "request/3: GET", %{bypass: bypass} do
    path = "/test/get"
    client = HTTPClient.client("http://localhost:#{bypass.port}")

    Bypass.expect_once(bypass, "GET", path, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == path

      Plug.Conn.resp(conn, 200, "")
    end)

    HTTPClient.request(:get, client, path)
  end

  test "request/3: POST with empty body", %{bypass: bypass} do
    client = HTTPClient.client("http://localhost:#{bypass.port}")
    path = "/test/post"

    Bypass.expect_once(bypass, "POST", path, fn conn ->
      assert conn
             |> Plug.Conn.read_body()
             |> elem(1)
             |> Jason.decode!() == %{}

      assert conn.method == "POST"
      assert conn.request_path == path

      Plug.Conn.resp(conn, 200, "")
    end)

    HTTPClient.request(:post, client, path)
  end

  test "request/4: POST", %{bypass: bypass} do
    client = HTTPClient.client("http://localhost:#{bypass.port}")
    path = "/test/post"
    body = %{"name" => "name"}

    Bypass.expect_once(bypass, "POST", path, fn conn ->
      assert conn
             |> Plug.Conn.read_body()
             |> elem(1)
             |> Jason.decode!() == body

      assert conn.method == "POST"
      assert conn.request_path == path

      Plug.Conn.resp(conn, 200, "")
    end)

    HTTPClient.request(:post, client, path, body)
  end
end
