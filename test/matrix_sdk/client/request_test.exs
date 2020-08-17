defmodule MatrixSDK.Client.RequestTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.Client.{Request, Auth}

  doctest Request

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

    test "register_user/3" do
      base_url = "http://test-server.url"
      password = "password"
      auth = Auth.login_dummy()

      request = Request.register_user(base_url, password, auth)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register"
      assert request.body.auth.type == "m.login.dummy"
      assert request.body.password == password
    end

    test "register_user/4 with options" do
      base_url = "http://test-server.url"
      password = "password"
      auth = Auth.login_dummy()

      opts = %{
        username: "username",
        device_id: "id",
        initial_device_display_name: "display name",
        inhibit_login: true
      }

      request = Request.register_user(base_url, password, auth, opts)

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

    test "registration_email_token/4" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1

      request = Request.registration_email_token(base_url, client_secret, email, send_attempt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register/email/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
    end

    test "registration_email_token/5 with options" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1
      opts = %{next_link: "nextlink.url"}

      request =
        Request.registration_email_token(base_url, client_secret, email, send_attempt, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register/email/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
      assert request.body.next_link == opts.next_link
    end

    test "registration_msisdn_token/5" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1

      request =
        Request.registration_msisdn_token(
          base_url,
          client_secret,
          country,
          phone_number,
          send_attempt
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register/msisdn/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
    end

    test "registration_msisdn_token/6 with options" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1
      opts = %{next_link: "nextlink.url"}

      request =
        Request.registration_msisdn_token(
          base_url,
          client_secret,
          country,
          phone_number,
          send_attempt,
          opts
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/register/msisdn/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
      assert request.body.next_link == opts.next_link
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

    test "password_email_token/4" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1

      request = Request.password_email_token(base_url, client_secret, email, send_attempt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password/email/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
    end

    test "password_email_token/5 with options" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1
      opts = %{next_link: "nextlink.url"}

      request = Request.password_email_token(base_url, client_secret, email, send_attempt, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password/email/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
      assert request.body.next_link == opts.next_link
    end

    test "password_msisdn_token/5" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1

      request =
        Request.password_msisdn_token(
          base_url,
          client_secret,
          country,
          phone_number,
          send_attempt
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password/msisdn/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
    end

    test "password_msisdn_token/6 with options" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1
      opts = %{next_link: "nextlink.url"}

      request =
        Request.password_msisdn_token(
          base_url,
          client_secret,
          country,
          phone_number,
          send_attempt,
          opts
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/password/msisdn/requestToken"
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
      assert request.body.next_link == opts.next_link
    end

    test "deactivate_account/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.deactivate_account(base_url, token)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/deactivate"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "deactivate_account/3 with options" do
      base_url = "http://test-server.url"
      token = "token"
      opts = %{auth: Auth.login_token(token)}

      request = Request.deactivate_account(base_url, token, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/deactivate"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.auth == opts.auth
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

    test "account_add_3pid/4" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      sid = "sid"

      request = Request.account_add_3pid(base_url, token, client_secret, sid)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/add"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.sid == sid
    end

    test "account_add_3pid/5" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      sid = "sid"
      opts = %{auth: auth = Auth.login_token(token)}

      request = Request.account_add_3pid(base_url, token, client_secret, sid, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/add"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.sid == sid
      assert request.body.auth == auth
    end

    test "account_bind_3pid/6" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      sid = "sid"
      id_server = "example.org"
      id_access_token = "abc123"

      request =
        Request.account_bind_3pid(base_url, token, client_secret, id_server, id_access_token, sid)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/bind"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.sid == sid
      assert request.body.id_server == id_server
      assert request.body.id_access_token == id_access_token
    end

    test "account_delete_3pid/4" do
      base_url = "http://test-server.url"
      token = "token"
      medium = "email"
      address = "example@example.org"

      request = Request.account_delete_3pid(base_url, token, medium, address)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/delete"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.medium == medium
      assert request.body.address == address
    end

    test "account_delete_3pid/5" do
      base_url = "http://test-server.url"
      token = "token"
      medium = "email"
      address = "example@example.org"
      id_server = "example.org"
      opt = %{id_server: id_server}

      request = Request.account_delete_3pid(base_url, token, medium, address, opt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/delete"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.medium == medium
      assert request.body.address == address
      assert request.body.id_server == id_server
    end

    test "account_unbind_3pid/4" do
      base_url = "http://test-server.url"
      token = "token"
      medium = "email"
      address = "example@example.org"

      request = Request.account_unbind_3pid(base_url, token, medium, address)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/unbind"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.medium == medium
      assert request.body.address == address
    end

    test "account_unbind_3pid/5" do
      base_url = "http://test-server.url"
      token = "token"
      medium = "email"
      address = "example@example.org"
      id_server = "example.org"
      opt = %{id_server: id_server}

      request = Request.account_unbind_3pid(base_url, token, medium, address, opt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/unbind"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.medium == medium
      assert request.body.address == address
      assert request.body.id_server == id_server
    end

    test "account_email_token/5" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      email = "example@example.org"
      send_attempt = 1

      request =
        Request.account_email_token(
          base_url,
          token,
          client_secret,
          email,
          send_attempt
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/email/requestToken"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
    end

    test "account_email_token/6" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      email = "example@example.org"
      send_attempt = 1
      next_link = "test-site.url"
      id_server = "id.example.org"
      id_access_token = "abc123"
      opts = %{next_link: next_link, id_server: id_server, id_access_token: id_access_token}

      request =
        Request.account_email_token(
          base_url,
          token,
          client_secret,
          email,
          send_attempt,
          opts
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/email/requestToken"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.email == email
      assert request.body.send_attempt == send_attempt
      assert request.body.id_server == id_server
      assert request.body.id_access_token == id_access_token
      assert request.body.next_link == next_link
    end

    test "account_msisdn_token/6" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1

      request =
        Request.account_msisdn_token(
          base_url,
          token,
          client_secret,
          country,
          phone_number,
          send_attempt
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/msisdn/requestToken"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
    end

    test "account_msisdn_token/7" do
      base_url = "http://test-server.url"
      token = "token"
      client_secret = "client_secret"
      country = "GB"
      phone_number = "07700900001"
      send_attempt = 1
      next_link = "test-site.url"
      id_server = "id.example.org"
      id_access_token = "abc123"
      opts = %{next_link: next_link, id_server: id_server, id_access_token: id_access_token}

      request =
        Request.account_msisdn_token(
          base_url,
          token,
          client_secret,
          country,
          phone_number,
          send_attempt,
          opts
        )

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/account/3pid/msisdn/requestToken"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body.client_secret == client_secret
      assert request.body.country == country
      assert request.body.phone_number == phone_number
      assert request.body.send_attempt == send_attempt
      assert request.body.id_server == id_server
      assert request.body.id_access_token == id_access_token
      assert request.body.next_link == next_link
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

  describe "getting events for a room:" do
    test "room_event/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      event_id = "$event"

      request = Request.room_event(base_url, token, room_id, event_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/event/%24event"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_state_event/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      event_type = "m.room.event"
      state_key = "@user:matrix.org"

      request = Request.room_state_event(base_url, token, room_id, event_type, state_key)

      assert request.method == :get
      assert request.base_url == base_url

      assert request.path ==
               "/_matrix/client/r0/rooms/%21room%3Atest-server.url/state/m.room.event/%40user%3Amatrix.org"

      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_state/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      request = Request.room_state(base_url, token, room_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/state"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_members/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      request = Request.room_members(base_url, token, room_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/members"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_members/4 with options" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      opts = %{
        at: "s123456789",
        membership: "join",
        not_membership: "invite"
      }

      request = Request.room_members(base_url, token, room_id, opts)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/members"
      assert request.headers == [{"Authorization", "Bearer " <> token}]

      assert request.query_params == [
               at: opts.at,
               membership: opts.membership,
               not_membership: opts.not_membership
             ]
    end

    test "room_joined_members/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      request = Request.room_joined_members(base_url, token, room_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/joined_members"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_messages/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      from = "t123456789"
      dir = "f"

      request = Request.room_messages(base_url, token, room_id, from, dir)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/messages"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.query_params == [dir: dir, from: from]
    end

    test "room_messages/6 with options" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      from = "t123456789"
      dir = "f"

      opts = %{to: "t987654321", limit: 10, filter: "filter"}

      request = Request.room_messages(base_url, token, room_id, from, dir, opts)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21room%3Atest-server.url/messages"
      assert request.headers == [{"Authorization", "Bearer " <> token}]

      assert request.query_params == [
               dir: dir,
               filter: opts.filter,
               from: from,
               limit: opts.limit,
               to: opts.to
             ]
    end
  end

  describe "sending events to a room:" do
    test "send_state_event/3" do
      base_url = "http://test-server.url"
      token = "token"

      state_event = %{
        content: %{join_rule: "private"},
        room_id: "!someroom:matrix.org",
        state_key: "",
        type: "m.room.join_rules"
      }

      request = Request.send_state_event(base_url, token, state_event)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{join_rule: "private"}

      assert request.path ==
               "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/state/m.room.join_rules/"
    end

    test "send_room_event/3" do
      base_url = "http://test-server.url"
      token = "token"

      room_event = %{
        content: %{body: "Fire! Fire! Fire!", msgtype: "m.text"},
        room_id: "!someroom:matrix.org",
        type: "m.room.message",
        transaction_id: "transaction_id"
      }

      request = Request.send_room_event(base_url, token, room_event)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{body: "Fire! Fire! Fire!", msgtype: "m.text"}

      assert request.path ==
               "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/send/m.room.message/transaction_id"
    end

    test "redact_room_event/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      event_id = "event_id"
      transaction_id = "transaction_id"

      request = Request.redact_room_event(base_url, token, room_id, event_id, transaction_id)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{}

      assert request.path ==
               "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id"
    end

    test "redact_room_event/6" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      event_id = "event_id"
      transaction_id = "transaction_id"
      opt = %{reason: "Indecent material"}

      request = Request.redact_room_event(base_url, token, room_id, event_id, transaction_id, opt)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{reason: "Indecent material"}

      assert request.path ==
               "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/redact/event_id/transaction_id"
    end
  end

  describe "room creation:" do
    test "create_room/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.create_room(base_url, token)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/createRoom"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{}
    end

    test "create_room/3" do
      base_url = "http://test-server.url"
      token = "token"

      opts = %{
        visibility: "public",
        room_alias_name: "chocolate",
        topic: "Some cool stuff about chocolate."
      }

      request = Request.create_room(base_url, token, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/createRoom"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == opts
    end
  end

  describe "room membership:" do
    test "joined_rooms/2" do
      base_url = "http://test-server.url"
      token = "token"

      request = Request.joined_rooms(base_url, token)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/joined_rooms"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_invite/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      request = Request.room_invite(base_url, token, room_id, user_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/invite"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id}
    end

    test "join_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      request = Request.join_room(base_url, token, room_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/join/%21someroom%3Amatrix.org"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "join_room/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      # Example from 0.6.1 docs
      opts = %{
        third_party_signed: %{
          sender: "@alice:example.org",
          mxid: "@bob:example.org",
          token: "random8nonce",
          signatures: %{
            "example.org": %{
              "ed25519:0": "some9signature"
            }
          }
        }
      }

      request = Request.join_room(base_url, token, room_id, opts)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/join/%21someroom%3Amatrix.org"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == opts
    end

    test "leave_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      request = Request.leave_room(base_url, token, room_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/leave"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "forget_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      request = Request.forget_room(base_url, token, room_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/forget"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
    end

    test "room_kick/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      request = Request.room_kick(base_url, token, room_id, user_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/kick"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id}
    end

    test "room_kick/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"
      opt = %{reason: "Eating all the chocolate."}

      request = Request.room_kick(base_url, token, room_id, user_id, opt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/kick"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id, reason: opt.reason}
    end

    test "room_ban/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      request = Request.room_ban(base_url, token, room_id, user_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/ban"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id}
    end

    test "room_ban/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"
      opt = %{reason: "Eating all the chocolate."}

      request = Request.room_ban(base_url, token, room_id, user_id, opt)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/ban"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id, reason: opt.reason}
    end

    test "room_unban/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      request = Request.room_unban(base_url, token, room_id, user_id)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/rooms/%21someroom%3Amatrix.org/unban"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{user_id: user_id}
    end
  end

  describe "room discovery and visibility:" do
    test "room_visibility/2" do
      base_url = "http://test-server.url"
      room_id = "!room:test-server.url"

      request = Request.room_visibility(base_url, room_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/directory/list/room/%21room%3Atest-server.url"
    end

    test "room_visibility/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      visibility = "public"

      request = Request.room_visibility(base_url, token, room_id, visibility)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/directory/list/room/%21room%3Atest-server.url"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{visibility: visibility}
    end

    test "public_rooms/1" do
      base_url = "http://test-server.url"
      request = Request.public_rooms(base_url)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/publicRooms"
    end

    test "public_rooms/2 with options" do
      base_url = "http://test-server.url"
      opts = %{limit: 10, since: "t123456789", server: "server"}
      request = Request.public_rooms(base_url, opts)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/publicRooms"

      assert request.query_params == [
               limit: opts.limit,
               server: opts.server,
               since: opts.since
             ]
    end

    test "public_rooms/3" do
      base_url = "http://test-server.url"
      token = "token"
      filters = %{limit: 10, since: "t123456789"}
      request = Request.public_rooms(base_url, token, filters)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/publicRooms"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == filters
    end

    test "public_rooms/4" do
      base_url = "http://test-server.url"
      token = "token"
      filters = %{limit: 10, since: "t123456789"}
      server = "server"
      request = Request.public_rooms(base_url, token, filters, server)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/publicRooms"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == filters
      assert request.query_params == [server: server]
    end
  end

  describe "user directory search:" do
    test "user_directory_search/3" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      request = Request.user_directory_search(base_url, token, search_term)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/user_directory/search"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{search_term: search_term}
    end

    test "user_directory_search/4 only language option" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      language = "en-US"
      options = %{language: language}
      request = Request.user_directory_search(base_url, token, search_term, options)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/user_directory/search"

      assert request.headers == [
               {"Authorization", "Bearer " <> token},
               {"Accept-Language", language}
             ]

      assert request.body == %{search_term: search_term}
    end

    test "user_directory_search/4 only limit option" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      limit = 42
      options = %{limit: limit}
      request = Request.user_directory_search(base_url, token, search_term, options)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/user_directory/search"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{search_term: search_term, limit: limit}
    end

    test "user_directory_search/4 both language and limit options" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      limit = 42
      language = "en-US"
      options = %{limit: limit, language: language}
      request = Request.user_directory_search(base_url, token, search_term, options)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/user_directory/search"

      assert request.headers == [
               {"Authorization", "Bearer " <> token},
               {"Accept-Language", language}
             ]

      assert request.body == %{search_term: search_term, limit: limit}
    end

    test "user_directory_search/4 garbage options" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      options = %{foo: "bar", bar: "foo"}
      request = Request.user_directory_search(base_url, token, search_term, options)

      assert request.method == :post
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/user_directory/search"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{search_term: search_term}
    end
  end

  describe "user profile:" do
    test "set_display_name/4" do
      base_url = "http://test-server.url"
      token = "token"
      user_id = "@user:matrix.org"
      display_name = "mickey"
      request = Request.set_display_name(base_url, token, user_id, display_name)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/profile/%40user%3Amatrix.org/displayname"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{displayname: display_name}
    end

    test "display_name/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      request = Request.display_name(base_url, user_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/profile/%40user%3Amatrix.org/displayname"
    end

    test "set_avatar_url/4" do
      base_url = "http://test-server.url"
      token = "token"
      user_id = "@user:matrix.org"
      avatar_url = "mxc://matrix.org/wefh34uihSDRGhw34"
      request = Request.set_avatar_url(base_url, token, user_id, avatar_url)

      assert request.method == :put
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/profile/%40user%3Amatrix.org/avatar_url"
      assert request.headers == [{"Authorization", "Bearer " <> token}]
      assert request.body == %{avatar_url: avatar_url}
    end

    test "avatar_url/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      request = Request.avatar_url(base_url, user_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/profile/%40user%3Amatrix.org/avatar_url"
    end

    test "user_profile/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      request = Request.user_profile(base_url, user_id)

      assert request.method == :get
      assert request.base_url == base_url
      assert request.path == "/_matrix/client/r0/profile/%40user%3Amatrix.org"
    end
  end
end
