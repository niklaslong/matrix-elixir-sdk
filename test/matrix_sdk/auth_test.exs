defmodule MatrixSDK.AuthTest do
  use ExUnit.Case

  alias MatrixSDK.Auth

  test "login_dummy/0" do
    assert Auth.login_dummy() == %{type: "m.login.dummy"}
  end

  test "login_token/1" do
    token = "token"
    auth = Auth.login_token(token)

    assert auth.type == "m.login.token"
    assert auth.token == token
  end

  test "login_recaptcha/1" do
    response = "response"
    auth = Auth.login_recaptcha(response)

    assert auth.type == "m.login.recaptcha"
    assert auth.response == response
  end

  test "login_email_identity/2" do
    sid = "sid"
    client_secret = "client_secret"
    auth = Auth.login_email_identity(sid, client_secret)
    [creds] = auth.threepidCreds

    assert auth.type == "m.login.email.identity"
    assert creds.sid == sid
    assert creds.client_secret == client_secret
  end

  test "login_msisdn/" do
    sid = "sid"
    client_secret = "client_secret"
    auth = Auth.login_msisdn(sid, client_secret)
    [creds] = auth.threepidCreds

    assert auth.type == "m.login.msisdn"
    assert creds.sid == sid
    assert creds.client_secret == client_secret
  end

  test "login_user/2" do
    user = "username"
    password = "password"
    auth = Auth.login_user(user, password)

    assert auth.type == "m.login.password"
    assert auth.password == password
    assert auth.identifier.type == "m.id.user"
    assert auth.identifier.user == user
  end

  test "login_3pid/3" do
    medium = "medium"
    address = "address"
    password = "password"
    auth = Auth.login_3pid(medium, address, password)

    assert auth.type == "m.login.password"
    assert auth.password == password
    assert auth.identifier.type == "m.id.thirdparty"
    assert auth.identifier.medium == medium
    assert auth.identifier.address == address
  end

  test "login_phone/3" do
    country = "CH"
    phone = "phone"
    password = "password"
    auth = Auth.login_phone(country, phone, password)

    assert auth.type == "m.login.password"
    assert auth.password == password
    assert auth.identifier.type == "m.id.phone"
    assert auth.identifier.country == country
    assert auth.identifier.phone == phone
  end

  test "put_session/2" do
    session_id = "session ID"
    assert Auth.put_session(%{}, session_id) == %{session: session_id}
  end
end
