defmodule MatrixSDK.APITest do
  use ExUnit.Case
  import Mox

  alias MatrixSDK.{API, HTTPClient, HTTPClientMock}
  alias Tesla

  setup :verify_on_exit!

  test "spec_versions/1: returns supported matrix spec" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :get, ^client, "/_matrix/client/versions" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.spec_versions(client)
  end

  test "server_discovery/1: returns discovery information about the domain" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :get, ^client, "/.well-known/matrix/client" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.server_discovery(client)
  end

  # User - login/logout

  test "logout/1: invalidates access token" do
    client = HTTPClient.client("some_base_url.yay", [{"Authorization", "Bearer token"}])

    expect(HTTPClientMock, :request, fn :post, ^client, "/_matrix/client/r0/logout" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.logout(client)
  end

  test "logout/2: invalidates access token" do
    expect(HTTPClientMock, :request, fn :post, client, "/_matrix/client/r0/logout" ->
      [headers] =
        Enum.find_value(client.pre, fn {middleware, _, value} ->
          if middleware == Tesla.Middleware.Headers, do: value
        end)

      assert Enum.member?(headers, {"Authorization", "Bearer token"})

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.logout("some_base_url.yay", "token")
  end

  #  User - registration

  test "register_user/2: registers a new guest user" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :post,
                                        ^client,
                                        "/_matrix/client/r0/register?kind=guest" ->
      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.register_user(client, :guest)
  end

  test "register_user/4: registers a new user" do
    client = HTTPClient.client("some_base_url.yay")

    expect(HTTPClientMock, :request, fn :post, ^client, "/_matrix/client/r0/register", body ->
      assert body.auth == %{type: "m.login.dummy"}
      assert body.username == "username"
      assert body.password == "password"

      {:ok, %Tesla.Env{}}
    end)

    assert {:ok, _} = API.register_user(client, :user, "username", "password")
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
