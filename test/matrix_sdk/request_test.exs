defmodule MatrixSDK.RequestTest do
  use ExUnit.Case
  alias MatrixSDK.{Request, Auth}

  doctest MatrixSDK.Request

  describe "server administration:" do
    test "spec_versions/1" do
      base_url = "http://test-server.url"
      request = Request.spec_versions(base_url)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/versions"
    end

    test "server_discovery/1" do
      base_url = "http://test-server.url"
      request = Request.server_discovery(base_url)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/.well-known/matrix/client"
    end

    test "server_capabilities/2" do
      base_url = "http://test-server.url"
      token = "token"
      request = Request.server_capabilities(base_url, token)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/capabilities"
    end
  end

  describe "session management:" do
    test "login/1" do
      base_url = "http://test-server.url"
      request = Request.login(base_url)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
    end

    test "login/2 token authentication" do
      base_url = "http://test-server.url"
      token = "token"
      auth = Auth.login_token(token)

      request = Request.login(base_url, auth)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
      assert request.body.type == "m.login.token"
      assert request.body.token == token
    end

    test "login/2 user and password authentication" do
      base_url = "http://test-server.url"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)

      request = Request.login(base_url, auth)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
      assert request.body.type == "m.login.password"
      assert request.body.identifier.type == "m.id.user"
      assert request.body.identifier.user == user
      assert request.body.password == password
    end

    test "login/3 token authentication with options" do
      base_url = "http://test-server.url"
      token = "token"
      auth = Auth.login_token(token)
      opts = %{device_id: "id", initial_device_display_name: "display name"}

      request = Request.login(base_url, auth, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
      assert request.body.type == "m.login.token"
      assert request.body.token == token
      assert request.body.device_id == opts.device_id
      assert request.body.initial_device_display_name == opts.initial_device_display_name
    end

    test "login/3 user and password authentication with options" do
      base_url = "http://test-server.url"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)
      opts = %{device_id: "id", initial_device_display_name: "display name"}

      request = Request.login(base_url, auth, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/login"
      assert request.body.type == "m.login.password"
      assert request.body.identifier.type == "m.id.user"
      assert request.body.identifier.user == user
      assert request.body.password == password
      assert request.body.device_id == opts.device_id
      assert request.body.initial_device_display_name == opts.initial_device_display_name
    end

    test "logout/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.logout(base_url, token)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/logout"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "logout_all/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.logout_all(base_url, token)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/logout/all"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end
  end

  describe "account registration:" do
    test "register_guest/1" do
      base_url = "http://test-server.url"
      request = Request.register_guest(base_url)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register?kind=guest"
    end

    test "register_guest/2 with options" do
      base_url = "http://test-server.url"
      opts = %{initial_device_display_name: "display name"}

      request = Request.register_guest(base_url, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register?kind=guest"
      assert request.body.initial_device_display_name == opts.initial_device_display_name
    end

    test "register_user/2" do
      base_url = "http://test-server.url"
      password = "password"

      request = Request.register_user(base_url, password)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register"
      assert request.body.auth.type == "m.login.dummy"
      assert request.body.password == password
    end

    test "register_user/3 with options" do
      base_url = "http://test-server.url"
      password = "password"

      opts = %{
        username: "username",
        device_id: "id",
        initial_device_display_name: "display name",
        inhibit_login: true
      }

      request = Request.register_user(base_url, password, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register"
      assert request.body.auth.type == "m.login.dummy"
      assert request.body.password == password
      assert request.body.username == opts.username
      assert request.body.device_id == opts.device_id
      assert request.body.initial_device_display_name == opts.initial_device_display_name
      assert request.body.inhibit_login == opts.inhibit_login
    end

    test "username_availability/2" do
      base_url = "http://test-server.url"
      username = "username"

      request = Request.username_availability(base_url, username)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register/available?username=#{username}"
    end
  end

  describe "account management:" do
    test "change_password/3 token authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      token = "token"
      auth = Auth.login_token(token)

      request = Request.change_password(base_url, new_password, auth)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password"
      assert request.body.new_password == new_password
      assert request.body.auth.type == "m.login.token"
      assert request.body.auth.token == token
    end

    test "change_password/3 user and password authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)

      request = Request.change_password(base_url, new_password, auth)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password"
      assert request.body.new_password == new_password
      assert request.body.auth.type == "m.login.password"
      assert request.body.auth.identifier.type == "m.id.user"
      assert request.body.auth.identifier.user == user
      assert request.body.auth.password == password
    end

    test "change_password/4 token authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      token = "token"
      auth = Auth.login_token(token)
      opts = %{logout_devices: true}

      request = Request.change_password(base_url, new_password, auth, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password"
      assert request.body.new_password == new_password
      assert request.body.auth.type == "m.login.token"
      assert request.body.auth.token == token
      assert request.body.logout_devices == true
    end

    test "change_password/4 user and password authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      user = "username"
      password = "password"
      auth = Auth.login_user(user, password)
      opts = %{logout_devices: true}

      request = Request.change_password(base_url, new_password, auth, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password"
      assert request.body.new_password == new_password
      assert request.body.auth.type == "m.login.password"
      assert request.body.auth.identifier.type == "m.id.user"
      assert request.body.auth.identifier.user == user
      assert request.body.auth.password == password
      assert request.body.logout_devices == true
    end
  end

  describe "user contact information:" do
    test "account_3pids/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.account_3pids(base_url, token)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end
  end

  describe "current account information:" do
    test "whoami/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.whoami(base_url, token)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/whoami"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end
  end

  describe "client-server syncing:" do
    test "sync/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.sync(base_url, token)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/sync"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
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

      request = Request.sync(base_url, token, opts)

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
    end
  end

  describe "room administration:" do
    test "room_discovery/1" do
      base_url = "http://test-server.url"
      request = Request.room_discovery(base_url)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/publicRooms"
    end
  end
end
