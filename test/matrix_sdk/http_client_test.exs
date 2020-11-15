defmodule MatrixSDK.HTTPClientTest do
  use ExUnit.Case, async: true

  alias MatrixSDK.HTTPClient
  alias MatrixSDK.API.{Request, Error}
  alias Tesla
  alias Jason

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

    test "GET with query params", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :get,
        base_url: base_url,
        path: path,
        query_params: [{:key, "value"}, {:query, "query"}]
      }

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == path
        assert conn.query_string == "key=value&query=query"

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

    test "POST with query params", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :post,
        base_url: base_url,
        path: path,
        query_params: [{:key, "value"}, {:query, "query"}]
      }

      Bypass.expect_once(bypass, "POST", path, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == path
        assert conn.query_string == "key=value&query=query"

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1)
               |> Jason.decode!() == %{}

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "PUT", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :put,
        base_url: base_url,
        path: path
      }

      Bypass.expect_once(bypass, "PUT", path, fn conn ->
        assert conn.method == "PUT"
        assert conn.request_path == path

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1)
               |> Jason.decode!() == %{}

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "PUT with query params", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :put,
        base_url: base_url,
        path: path,
        query_params: [{:key, "value"}, {:query, "query"}]
      }

      Bypass.expect_once(bypass, "PUT", path, fn conn ->
        assert conn.method == "PUT"
        assert conn.request_path == path
        assert conn.query_string == "key=value&query=query"

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1)
               |> Jason.decode!() == %{}

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "DELETE", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :delete,
        base_url: base_url,
        path: path
      }

      Bypass.expect_once(bypass, "DELETE", path, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == path

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1) === ""

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "DELETE with query params", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :delete,
        base_url: base_url,
        path: path,
        query_params: [{:key, "value"}, {:query, "query"}]
      }

      Bypass.expect_once(bypass, "DELETE", path, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == path
        assert conn.query_string == "key=value&query=query"

        assert conn
               |> Plug.Conn.read_body()
               |> elem(1) === ""

        Plug.Conn.resp(conn, 200, "")
      end)

      assert HTTPClient.do_request(request)
    end

    test "returns an Error struct for 4xx responses", %{bypass: bypass} do
      base_url = "http://localhost:#{bypass.port}"
      path = "/test/path"

      request = %Request{
        method: :get,
        base_url: base_url,
        path: path
      }

      Bypass.expect_once(bypass, "GET", path, fn conn ->
        # This header is required for Mint to know how to parse the response
        # body.
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(
          400,
          Jason.encode!(%{
            errcode: "M_UNKNOWN",
            error: "An unknown error occurred"
          })
        )
      end)

      #  Only testing the struct is correct, unit testing field parsing is done
      # in the `MatrixSDK.API.Error` module.
      assert %Error{} = HTTPClient.do_request(request)
    end

    test "returns an error tuple when Tesla fails" do
      request = %Request{
        method: :get,
        #  Not setting the port will result in a Mint transport error.
        base_url: "http://localhost",
        path: "/test/path"
      }

      assert {:error, _} = HTTPClient.do_request(request)
    end
  end
end
