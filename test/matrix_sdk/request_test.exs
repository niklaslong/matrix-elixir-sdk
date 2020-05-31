defmodule MatrixSDK.RequestTest do
  use ExUnit.Case
  alias MatrixSDK.Request

  test "spec_versions/0" do
    request = Request.spec_versions()

    assert request.method == :get
    assert request.path == "/_matrix/client/versions"
  end

  test "server_discovery/0" do
    request = Request.server_discovery()

    assert request.method == :get
    assert request.path == "/.well-known/matrix/client"
  end

  test "login/1" do
    request = Request.login()

    assert request.method == :get
    assert request.path == "/_matrix/client/r0/login"
  end

  test "login/2" do
    request = Request.login("username", "password")

    assert request.method == :post
    assert request.path == "/_matrix/client/r0/login"
    assert request.body.type == "m.login.password"
    assert request.body.user == "username"
    assert request.body.password == "password"
  end

  test "logout/1" do
    request = Request.logout("token")

    assert request.method == :post
    assert request.path == "/_matrix/client/r0/logout"
    assert request.headers == [{"Authorization", "Bearer token"}]
  end

  test "register_user/0" do
    request = Request.register_user()

    assert request.method == :post
    assert request.path == "/_matrix/client/r0/register?kind=guest"
  end

  test "register_user/2" do
    request = Request.register_user("username", "password")

    assert request.method == :post
    assert request.path == "/_matrix/client/r0/register"
    assert request.body.auth.type == "m.login.dummy"
    assert request.body.username == "username"
    assert request.body.password == "password"
  end

  test "room_discovery/0" do
    request = Request.room_discovery()

    assert request.method == :get
    assert request.path == "/_matrix/client/r0/publicRooms"
  end
end
