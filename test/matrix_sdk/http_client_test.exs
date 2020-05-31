defmodule MatrixSDK.HTTPClientTest do
  use ExUnit.Case

  alias MatrixSDK.{Request, HTTPClient}
  alias Tesla

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "client/1: returns Tesla client" do
    test "with default headers" do
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

    test "with custom headers" do
      url = "http://test.url"
      client = %Tesla.Client{} = HTTPClient.client(url, [{"Custom-Header", "value"}])

      assert client.adapter == {Tesla.Adapter.Mint, :call, [[]]}
      assert client.fun == nil
      assert client.post == []

      assert client.pre == [
               {Tesla.Middleware.BaseUrl, :call, [url]},
               {Tesla.Middleware.Headers, :call,
                [[{"Accept", "application/json'"}, {"Custom-Header", "value"}]]},
               {Tesla.Middleware.JSON, :call, [[]]}
             ]
    end
  end

  describe "do_request/1:" do
    test "GET", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :get,
        base_url: base_url,
        path: path
      }

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == path

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "POST", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :post,
        base_url: base_url,
        path: path
      }

      Bypass.expect_once(bypass, "POST", path, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == path

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1)
               |> Jason.decode!() == %{}

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end
  end

  # –––––––

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
