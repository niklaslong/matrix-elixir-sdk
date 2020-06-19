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

    test "register_user/3 registers a new user" do
      base_url = "http://test.url"
      password = "password"
      auth = MatrixSDK.Auth.login_dummy()
      expected_request = Request.register_user(base_url, password, auth)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_user(base_url, password, auth)
    end

    test "register_user/4 registers a new user with options" do
      base_url = "http://test.url"
      password = "password"
      auth = MatrixSDK.Auth.login_dummy()

      opts = %{
        username: "username",
        device_id: "id",
        initial_device_display_name: "display name",
        inhibit_login: true
      }

      expected_request = Request.register_user(base_url, password, auth, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_user(base_url, password, auth, opts)
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

    test "register_email/4" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1

      expected_request = Request.register_email(base_url, client_secret, email, send_attempt)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_email(base_url, client_secret, email, send_attempt)
    end

    test "register_email/5 with options" do
      base_url = "http://test-server.url"
      client_secret = "secret"
      email = "email@test.url"
      send_attempt = 1
      opts = %{id_access_token: "id_token", next_link: "nextlink.url"}

      expected_request =
        Request.register_email(base_url, client_secret, email, send_attempt, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.register_email(base_url, client_secret, email, send_attempt, opts)
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
    test "room_event/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      event_id = "$event"

      expected_request = Request.room_event(base_url, token, room_id, event_id)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_event(base_url, token, room_id, event_id)
    end

    test "room_state_event/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      event_type = "m.room.event"
      state_key = "@user:matrix.org"

      expected_request = Request.room_state_event(base_url, token, room_id, event_type, state_key)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_state_event(base_url, token, room_id, event_type, state_key)
    end

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

    test "room_joined_members/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"

      expected_request = Request.room_joined_members(base_url, token, room_id)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_joined_members(base_url, token, room_id)
    end

    test "room_messages/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      from = "t123456789"
      dir = "f"

      expected_request = Request.room_messages(base_url, token, room_id, from, dir)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_messages(base_url, token, room_id, from, dir)
    end

    test "room_messages/6 with options" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      from = "t123456789"
      dir = "f"

      opts = %{to: "t987654321", limit: 10, filter: "filter"}

      expected_request = Request.room_messages(base_url, token, room_id, from, dir, opts)

      assert assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_messages(base_url, token, room_id, from, dir, opts)
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

      expected_request = Request.send_state_event(base_url, token, state_event)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.send_state_event(base_url, token, state_event)
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

      expected_request = Request.send_room_event(base_url, token, room_event)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.send_room_event(base_url, token, room_event)
    end

    test "redact_room_event/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      event_id = "event_id"
      transaction_id = "transaction_id"

      expected_request =
        Request.redact_room_event(base_url, token, room_id, event_id, transaction_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.redact_room_event(base_url, token, room_id, event_id, transaction_id)
    end

    test "redact_room_event/6" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      event_id = "event_id"
      transaction_id = "transaction_id"
      opt = %{reason: "Indecent material"}

      expected_request =
        Request.redact_room_event(base_url, token, room_id, event_id, transaction_id, opt)

      assert_client_mock_got(expected_request)

      assert {:ok, _} =
               API.redact_room_event(base_url, token, room_id, event_id, transaction_id, opt)
    end
  end

  describe "room creation:" do
    test "create_room/2" do
      base_url = "http://test-server.url"
      token = "token"

      expected_request = Request.create_room(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.create_room(base_url, token)
    end

    test "create_room/3" do
      base_url = "http://test-server.url"
      token = "token"

      opts = %{
        visibility: "public",
        room_alias_name: "chocolate",
        topic: "Some cool stuff about chocolate."
      }

      expected_request = Request.create_room(base_url, token, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.create_room(base_url, token, opts)
    end
  end

  describe "room membership:" do
    test "joined_rooms/2" do
      base_url = "http://test-server.url"
      token = "token"

      expected_request = Request.joined_rooms(base_url, token)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.joined_rooms(base_url, token)
    end

    test "room_invite/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      expected_request = Request.room_invite(base_url, token, room_id, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_invite(base_url, token, room_id, user_id)
    end

    test "join_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      expected_request = Request.join_room(base_url, token, room_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.join_room(base_url, token, room_id)
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

      expected_request = Request.join_room(base_url, token, room_id, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.join_room(base_url, token, room_id, opts)
    end

    test "leave_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      expected_request = Request.leave_room(base_url, token, room_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.leave_room(base_url, token, room_id)
    end

    test "forget_room/3" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"

      expected_request = Request.forget_room(base_url, token, room_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.forget_room(base_url, token, room_id)
    end

    test "room_kick/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      expected_request = Request.room_kick(base_url, token, room_id, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_kick(base_url, token, room_id, user_id)
    end

    test "room_kick/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"
      opt = %{reason: "Eating all the chocolate."}

      expected_request = Request.room_kick(base_url, token, room_id, user_id, opt)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_kick(base_url, token, room_id, user_id, opt)
    end

    test "room_ban/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      expected_request = Request.room_ban(base_url, token, room_id, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_ban(base_url, token, room_id, user_id)
    end

    test "room_ban/5" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"
      opt = %{reason: "Eating all the chocolate."}

      expected_request = Request.room_ban(base_url, token, room_id, user_id, opt)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_ban(base_url, token, room_id, user_id, opt)
    end

    test "room_unban/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!someroom:matrix.org"
      user_id = "@user:matrix.org"

      expected_request = Request.room_unban(base_url, token, room_id, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_unban(base_url, token, room_id, user_id)
    end
  end

  describe "room discovery and visibility:" do
    test "room_visibility/2" do
      base_url = "http://test-server.url"
      room_id = "!room:test-server.url"

      expected_request = Request.room_visibility(base_url, room_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_visibility(base_url, room_id)
    end

    test "room_visibility/4" do
      base_url = "http://test-server.url"
      token = "token"
      room_id = "!room:test-server.url"
      visibility = "public"

      expected_request = Request.room_visibility(base_url, token, room_id, visibility)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.room_visibility(base_url, token, room_id, visibility)
    end

    test "public_rooms/1" do
      base_url = "http://test.url"
      expected_request = Request.public_rooms(base_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.public_rooms(base_url)
    end

    test "public_rooms/2 with options" do
      base_url = "http://test-server.url"
      opts = %{limit: 10, since: "t123456789", server: "server"}

      expected_request = Request.public_rooms(base_url, opts)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.public_rooms(base_url, opts)
    end

    test "public_rooms/3" do
      base_url = "http://test-server.url"
      token = "token"
      filters = %{limit: 10, since: "t123456789"}

      expected_request = Request.public_rooms(base_url, token, filters)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.public_rooms(base_url, token, filters)
    end

    test "public_rooms/4" do
      base_url = "http://test-server.url"
      token = "token"
      filters = %{limit: 10, since: "t123456789"}
      server = "server"

      expected_request = Request.public_rooms(base_url, token, filters, server)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.public_rooms(base_url, token, filters, server)
    end
  end

  describe "user directory search:" do
    test "user_directory_search/3" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"

      expected_request = Request.user_directory_search(base_url, token, search_term)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.user_directory_search(base_url, token, search_term)
    end

    test "user_directory_search/4" do
      base_url = "http://test-server.url"
      token = "token"
      search_term = "mickey"
      limit = 42
      language = "en-US"
      options = %{limit: limit, language: language}

      expected_request = Request.user_directory_search(base_url, token, search_term, options)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.user_directory_search(base_url, token, search_term, options)
    end
  end

  describe "user profile:" do
    test "set_display_name/4" do
      base_url = "http://test-server.url"
      token = "token"
      user_id = "@user:matrix.org"
      display_name = "mickey"
      expected_request = Request.set_display_name(base_url, token, user_id, display_name)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.set_display_name(base_url, token, user_id, display_name)
    end

    test "display_name/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      expected_request = Request.display_name(base_url, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.display_name(base_url, user_id)
    end

    test "set_avatar_url/4" do
      base_url = "http://test-server.url"
      token = "token"
      user_id = "@user:matrix.org"
      avatar_url = "mxc://matrix.org/wefh34uihSDRGhw34"
      expected_request = Request.set_avatar_url(base_url, token, user_id, avatar_url)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.set_avatar_url(base_url, token, user_id, avatar_url)
    end

    test "avatar_url/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      expected_request = Request.avatar_url(base_url, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.avatar_url(base_url, user_id)
    end

    test "user_profile/2" do
      base_url = "http://test-server.url"
      user_id = "@user:matrix.org"
      expected_request = Request.user_profile(base_url, user_id)

      assert_client_mock_got(expected_request)
      assert {:ok, _} = API.user_profile(base_url, user_id)
    end
  end

  defp assert_client_mock_got(expected_request) do
    expect(HTTPClientMock, :do_request, fn %Request{} = request ->
      assert Map.equal?(request, expected_request)

      {:ok, %Tesla.Env{}}
    end)
  end
end
