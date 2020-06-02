defmodule MatrixSDK.APITest do
  use ExUnit.Case
  import Mox

  alias MatrixSDK.{API, Request, HTTPClient, HTTPClientMock}
  alias Tesla

  setup :verify_on_exit!

  test "spec_versions/1: returns supported matrix spec" do
    base_url = "http://test.url"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/versions"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.spec_versions(base_url)
  end

  test "server_discovery/1: returns discovery information about the domain" do
    base_url = "http://test.url"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/.well-known/matrix/client"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.server_discovery(base_url)
  end

  # User - login/logout

  test "login/1: returns login flows" do
    base_url = "http://test.url"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.login(base_url)
  end

  test "login/3: returns login flows" do
    base_url = "http://test.url"
    username = "username"
    password = "password"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
      assert request.body.type == "m.login.password"
      assert request.body.user == "username"
      assert request.body.password == "password"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.login(base_url, username, password)
  end

  test "logout/2: invalidates access token" do
    base_url = "http://test.url"
    token = "token"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/logout"
      assert Enum.member?(request.headers, {"Authorization", "Bearer " <> token})

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.logout(base_url, token)
  end

  #  User - registration

  test "register_user/1: registers a new guest user" do
    base_url = "http://test.url"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register?kind=guest"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.register_user(base_url)
  end

  test "register_user/3: registers a new user" do
    base_url = "http://test.url"
    username = "username"
    password = "password"

    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register"
      assert request.body.auth.type == "m.login.dummy"
      assert request.body.username == username
      assert request.body.password == password

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.register_user(base_url, username, password)
  end

  # Rooms

  test "room_discovery/1: returns public rooms on server" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :get, ^client, "/_matrix/client/r0/publicRooms" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.room_discovery(client)
  end
end
