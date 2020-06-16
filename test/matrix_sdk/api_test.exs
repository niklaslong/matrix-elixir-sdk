defmodule MatrixSDK.APITest do
  use ExUnit.Case
  import Mox

  alias MatrixSDK.{API, Request, Auth, HTTPClientMock}
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

    test "server_capabilities/2" do
      base_url = "http://test-server.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/capabilities"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.server_capabilities(base_url, token)
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
      auth = Auth.login_token(token)

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.token"
        assert request.body.token == token

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, auth)
    end

    test "login/2 user and password authentication" do
      base_url = "http://test.url"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.password"
        assert request.body.identifier.type == "m.id.user"
        assert request.body.identifier.user == user
        assert request.body.password == password

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.login(base_url, auth)
    end

    test "login/3 token authentication with options" do
      base_url = "http://test.url"
      token = "token"
      auth = Auth.login_token(token)
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

      assert {:ok, _} = API.login(base_url, auth, opts)
    end

    test "login/3 user and password authentication with options" do
      base_url = "http://test.url"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)
      opts = %{device_id: "id", initial_device_display_name: "display name"}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/login"
        assert request.body.type == "m.login.password"
        assert request.body.identifier.type == "m.id.user"
        assert request.body.identifier.user == user
        assert request.body.password == password
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

    test "username_availability/2" do
      base_url = "http://test-server.url"
      username = "username"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/register/available?username=#{username}"

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.username_availability(base_url, username)
    end
  end

  describe "account management:" do
    test "change_password/3 token authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      token = "token"
      auth = Auth.login_token(token)

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/password"
        assert request.body.new_password == new_password
        assert request.body.auth.type == "m.login.token"
        assert request.body.auth.token == token

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.change_password(base_url, new_password, auth)
    end

    test "change_password/3 user and password authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/password"
        assert request.body.new_password == new_password
        assert request.body.auth.type == "m.login.password"
        assert request.body.auth.identifier.type == "m.id.user"
        assert request.body.auth.identifier.user == user
        assert request.body.auth.password == password

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.change_password(base_url, new_password, auth)
    end

    test "change_password/4 token authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      token = "token"
      auth = Auth.login_token(token)
      opts = %{logout_devices: true}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/password"
        assert request.body.new_password == new_password
        assert request.body.auth.type == "m.login.token"
        assert request.body.auth.token == token
        assert request.body.logout_devices == true

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.change_password(base_url, new_password, auth, opts)
    end

    test "change_password/4 user and password authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)
      opts = %{logout_devices: true}

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :post
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/password"
        assert request.body.new_password == new_password
        assert request.body.auth.type == "m.login.password"
        assert request.body.auth.identifier.type == "m.id.user"
        assert request.body.auth.identifier.user == user
        assert request.body.auth.password == password
        assert request.body.logout_devices == true

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.change_password(base_url, new_password, auth, opts)
    end
  end

  describe "user contact information:" do
    test "account_3pids/2" do
      base_url = "http://test-server.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/3pid"
        assert request.headers == [{"Authorization", "Bearer " <> token}]

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.account_3pids(base_url, token)
    end
  end

  describe "current account information:" do
    test "whoami/2" do
      base_url = "http://test-server.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/account/whoami"
        assert request.headers == [{"Authorization", "Bearer " <> token}]

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.whoami(base_url, token)
    end
  end

  describe "client-server syncing:" do
    test "sync/2" do
      base_url = "http://test-server.url"
      token = "token"

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/sync"
        assert request.headers == [{"Authorization", "Bearer " <> token}]

        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.sync(base_url, token)
    end

    test "sync/3 with options" do
      base_url = "http://test-server.url"
      token = "token"

      opts = %{
        since: "s123456789",
        filter: "filter",
        full_state: true,
        set_presence: "online",
        timeout: 1000
      }

      expect(HTTPClientMock, :do_request, fn %Request{} = request ->
        assert request.method == :get
        assert request.base_url == base_url
        assert request.path == "/_matrix/client/r0/sync"

        assert request.query_params == [
                 {:filter, opts.filter},
                 {:full_state, opts.full_state},
                 {:set_presence, opts.set_presence},
                 {:since, opts.since},
                 {:timeout, opts.timeout}
               ]

        assert request.headers == [{"Authorization", "Bearer " <> token}]
        {:ok, %Tesla.Env{}}
      end)

      assert {:ok, _} = API.sync(base_url, token, opts)
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
