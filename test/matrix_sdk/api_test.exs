defmodule MatrixSDK.APITest do
  use ExUnit.Case, async: true
  import Mox

  alias MatrixSDK.{API, Request, Auth, HTTPClientMock}
  alias Tesla

  setup :verify_on_exit!

  describe "server administration:" do
    test "spec_versions/1 returns supported matrix spec" do
      base_url = "http://test.url"
      expected_request = Request.spec_versions(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.spec_versions(base_url)
    end

    test "server_discovery/1 returns discovery information about the domain" do
      base_url = "http://test.url"
      expected_request = Request.server_discovery(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.server_discovery(base_url)
    end

    test "server_capabilities/2" do
      base_url = "http://test-server.url"
      token = "token"
      expected_request = Request.server_capabilities(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.server_capabilities(base_url, token)
    end
  end

  describe "session management:" do
    test "login/1 returns login flows" do
      base_url = "http://test.url"
      expected_request = Request.login(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.login(base_url)
    end

    test "login/2 token authentication" do
      base_url = "http://test.url"
      auth = Auth.login_token("token")
      expected_request = Request.login(base_url, auth)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.login(base_url, auth)
    end

    test "login/2 user and password authentication" do
      base_url = "http://test.url"
      auth = Auth.login_user("username", "password")
      expected_request = Request.login(base_url, auth)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.login(base_url, auth)
    end

    test "login/3 token authentication with options" do
      base_url = "http://test.url"
      auth = Auth.login_token("token")
      opts = %{device_id: "id", initial_device_display_name: "display name"}
      expected_request = Request.login(base_url, auth, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.login(base_url, auth, opts)
    end

    test "login/3 user and password authentication with options" do
      base_url = "http://test.url"
      auth = Auth.login_user("username", "password")
      opts = %{device_id: "id", initial_device_display_name: "display name"}
      expected_request = Request.login(base_url, auth, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.login(base_url, auth, opts)
    end

    test "logout/2 invalidates access token" do
      base_url = "http://test.url"
      token = "token"
      expected_request = Request.logout(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.logout(base_url, token)
    end

    test "logout_all/2 invalidates all access token" do
      base_url = "http://test.url"
      token = "token"
      expected_request = Request.logout_all(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.logout_all(base_url, token)
    end
  end

  describe "account registration:" do
    test "register_guest/1 registers a new guest user" do
      base_url = "http://test.url"
      expected_request = Request.register_guest(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_guest(base_url)
    end

    test "register_guest/2 registers a new guest user with options" do
      base_url = "http://test.url"
      opts = %{initial_device_display_name: "display name"}
      expected_request = Request.register_guest(base_url, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_guest(base_url, opts)
    end

    test "register_user/2 registers a new user" do
      base_url = "http://test.url"
      password = "password"
      expected_request = Request.register_user(base_url, password)

      assert_client_mock_got(expected_request)
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

      expected_request = Request.register_user(base_url, password, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_user(base_url, password, opts)
    end

    test "username_availability/2" do
      base_url = "http://test-server.url"
      username = "username"
      expected_request = Request.username_availability(base_url, username)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.username_availability(base_url, username)
    end
  end

  describe "account management:" do
    test "change_password/3 token authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      auth = Auth.login_token("token")
      expected_request = Request.change_password(base_url, new_password, auth)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.change_password(base_url, new_password, auth)
    end

    test "change_password/3 user and password authentication" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      auth = Auth.login_user("username", "password")
      expected_request = Request.change_password(base_url, new_password, auth)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.change_password(base_url, new_password, auth)
    end

    test "change_password/4 token authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      auth = Auth.login_token("token")
      opts = %{logout_devices: true}
      expected_request = Request.change_password(base_url, new_password, auth, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.change_password(base_url, new_password, auth, opts)
    end

    test "change_password/4 user and password authentication with options" do
      base_url = "http://test-server.url"
      new_password = "new_password"
      auth = Auth.login_user("username", "password")
      opts = %{logout_devices: true}
      expected_request = Request.change_password(base_url, new_password, auth, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.change_password(base_url, new_password, auth, opts)
    end
  end

  describe "user contact information:" do
    test "account_3pids/2" do
      base_url = "http://test-server.url"
      token = "token"
      expected_request = Request.account_3pids(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.account_3pids(base_url, token)
    end
  end

  describe "current account information:" do
    test "whoami/2" do
      base_url = "http://test-server.url"
      token = "token"
      expected_request = Request.whoami(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.whoami(base_url, token)
    end
  end

  describe "client-server syncing:" do
    test "sync/2" do
      base_url = "http://test-server.url"
      token = "token"
      expected_request = Request.sync(base_url, token)

      assert_client_mock_got(expected_request)
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

      expected_request = Request.sync(base_url, token, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.sync(base_url, token, opts)
    end
  end

  describe "getting events for a room:" do
    test "room_state/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      expected_request = Request.room_state(base_url, token, room_id)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_state(base_url, token, room_id)
    end

    test "room_members/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      expected_request = Request.room_members(base_url, token, room_id)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_members(base_url, token, room_id)
    end

    test "room_members/4 with options" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      opts = %{
        at: "t123456789",
        membership: "join",
        not_membership: "invite"
      }

      expected_request = Request.room_members(base_url, token, room_id, opts)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_members(base_url, token, room_id, opts)
    end
  end

  describe "room administration:" do
    test "room_discovery/1 returns public rooms on server" do
      base_url = "http://test.url"
      expected_request = Request.room_discovery(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_discovery(base_url)
    end
  end

  defp assert_client_mock_got(expected_request) do
    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert Map.equal?(request, expected_request)

      {:ok, %Tesla.Env{}}
    end)
  end
end
