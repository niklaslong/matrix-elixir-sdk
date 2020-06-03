defmodule MatrixSDK.RequestTest do
  use ExUnit.Case
  alias MatrixSDK.Request

  doctest MatrixSDK.Request

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

  test "login/1" do
    base_url = "http://test-server.url"
    request = Request.login(base_url)

    assert request.method == :get
    assert request.base_url == base_url
    assert request.path == "/_matrix/client/r0/login"
  end

  test "login/2" do
    base_url = "http://test-server.url"
    username = "username"
    password = "password"
    request = Request.login(base_url, %{user: username, password: password})

    assert request.method == :post
    assert request.base_url == base_url
    assert request.path == "/_matrix/client/r0/login"
    assert request.body.type == "m.login.password"
    assert request.body.identifier.type == "m.id.user"
    assert request.body.identifier.user == username
    assert request.body.password == password
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

  test "register_user/1" do
    base_url = "http://test-server.url"
    request = Request.register_user(base_url)

    assert request.method == :post
    assert request.base_url == base_url
    assert request.path == "/_matrix/client/r0/register?kind=guest"
  end

  test "register_user/3" do
    base_url = "http://test-server.url"
    username = "username"
    password = "password"
    request = Request.register_user(base_url, username, password)

    assert request.method == :post
    assert request.base_url == base_url
    assert request.path == "/_matrix/client/r0/register"
    assert request.body.auth.type == "m.login.dummy"
    assert request.body.username == username
    assert request.body.password == password
  end

  test "room_discovery/1" do
    base_url = "http://test-server.url"
    request = Request.room_discovery(base_url)

    assert request.method == :get
    assert request.base_url == base_url
    assert request.path == "/_matrix/client/r0/publicRooms"
  end
end
