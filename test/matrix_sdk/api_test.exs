defmodule MatrixSDK.APITest do
  use ExUnit.Case
  import Mox

  alias MatrixSDK.{API, Request, HTTPClientMock}
  alias Tesla

  setup :verify_on_exit!

  describe "server administration:" do
    test "spec_versions/1 returns supported matrix spec" do
      base_url = "http://test.url"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/versions"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.spec_versions(base_url)
    end

    test "server_discovery/1 returns discovery information about the domain" do
      base_url = "http://test.url"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/.well-known/matrix/client"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.server_discovery(base_url)
    end
  end

  describe "session management:" do
    test "login/1 returns login flows" do
      base_url = "http://test.url"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url)
    end

    test "login/2 token authentication" do
      base_url = "http://test.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.token"
        assert request.body.token == token

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, token)
    end

    test "login/2 user and password authentication" do
      base_url = "http://test.url"
      auth = %{user: "username", password: "password"}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.password"
        assert request.body.identifier.type == "m.id.user"
        assert request.body.identifier.user == auth.user
        assert request.body.password == auth.password

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, auth)
    end

    test "login/3 token authentication with options" do
      base_url = "http://test.url"
      token = "token"
      opts = %{device_id: "id", initial_device_display_name: "display name"}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.token"
        assert request.body.token == token
        assert request.body.device_id == opts.device_id
        assert request.body.initial_device_display_name == opts.initial_device_display_name

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, token, opts)
    end

    test "login/3 user and password authentication with options" do
      base_url = "http://test.url"
      auth = %{user: "username", password: "password"}
      opts = %{device_id: "id", initial_device_display_name: "display name"}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.password"
        assert request.body.identifier.type == "m.id.user"
        assert request.body.identifier.user == auth.user
        assert request.body.password == auth.password
        assert request.body.device_id == opts.device_id
        assert request.body.initial_device_display_name == opts.initial_device_display_name

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, auth, opts)
    end

    test "logout/2 invalidates access token" do
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

    test "logout_all/2 invalidates all access token" do
      base_url = "http://test.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/logout/all"
        assert Enum.member?(request.headers, {"Authorization", "Bearer " <> token})

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.logout_all(base_url, token)
    end
  end

  describe "account registration:" do
    test "register_guest/1 registers a new guest user" do
      base_url = "http://test.url"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/register?kind=guest"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.register_guest(base_url)
    end

    test "register_guest/2 registers a new guest user with options" do
      base_url = "http://test.url"
      opts = %{initial_device_display_name: "display name"}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/register?kind=guest"
        assert request.body.initial_device_display_name == opts.initial_device_display_name

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.register_guest(base_url, opts)
    end

    test "register_user/2 registers a new user" do
      base_url = "http://test.url"
      password = "password"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/register"
        assert request.body.auth.type == "m.login.dummy"
        assert request.body.password == password

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.register_user(base_url, password)
    end

    test "register_user/3 registers a new user with options" do
      base_url = "http://test.url"
      password = "password"

      opts = %{
        username: "username",
        device_id: "id",
        initial_device_display_name: "display name",
        inhibit_login: true
      }

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/register"
        assert request.body.auth.type == "m.login.dummy"
        assert request.body.password == password
        assert request.body.username == opts.username
        assert request.body.device_id == opts.device_id
        assert request.body.initial_device_display_name == opts.initial_device_display_name
        assert request.body.inhibit_login == opts.inhibit_login

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.register_user(base_url, password, opts)
    end
  end

  describe "room administration:" do
    test "room_discovery/1 returns public rooms on server" do
      base_url = "http://test.url"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/publicRooms"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.room_discovery(base_url)
    end
  end
end
