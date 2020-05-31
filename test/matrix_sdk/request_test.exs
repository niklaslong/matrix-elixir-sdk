defmodule MatrixSDK.RequestTest do
  use ExUnit.Case
  alias MatrixSDK.Request

  test "spec_versions/1" do
    request = Request.spec_versions("http://test-server.url")

    assert request.method == :get
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/versions"
  end

  test "server_discovery/1" do
    request = Request.server_discovery("http://test-server.url")

    assert request.method == :get
    assert request.base_url == "http://test-server.url"
    assert request.path == "/.well-known/matrix/client"
  end

  test "login/1" do
    request = Request.login("http://test-server.url")

    assert request.method == :get
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/login"
  end

  test "login/3" do
    request = Request.login("http://test-server.url", "username", "password")

    assert request.method == :post
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/login"
    assert request.body.type == "m.login.password"
    assert request.body.user == "username"
    assert request.body.password == "password"
  end

  test "logout/2" do
    request = Request.logout("http://test-server.url", "token")

    assert request.method == :post
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/logout"
    assert request.headers == [{"Authorization", "Bearer token"}]
  end

  test "register_user/1" do
    request = Request.register_user("http://test-server.url")

    assert request.method == :post
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/register?kind=guest"
  end

  test "register_user/3" do
    request = Request.register_user("http://test-server.url", "username", "password")

    assert request.method == :post
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/register"
    assert request.body.auth.type == "m.login.dummy"
    assert request.body.username == "username"
    assert request.body.password == "password"
  end

  test "room_discovery/1" do
    request = Request.room_discovery("http://test-server.url")

    assert request.method == :get
    assert request.base_url == "http://test-server.url"
    assert request.path == "/_matrix/client/r0/publicRooms"
  end
end
