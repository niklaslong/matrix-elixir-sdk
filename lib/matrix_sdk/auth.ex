defmodule MatrixSDK.Auth do
  def dummy(), do: %{type: "m.login.dummy"}
  def token(token), do: %{type: "m.login.token", token: token}

  def password(identifier, password),
    do: %{type: "m.login.password", identifier: identifier, password: password}

  def user_identifier(user), do: %{type: "m.id.user", user: user}

  def third_party_identifier(medium, address),
    do: %{type: "m.id.thirdparty", medium: medium, address: address}

  def phone_identifier(country, phone),
    do: %{type: "m.id.phone", country: country, phone: phone}

  def put_session(map, session_id), do: Map.put(map, :session, session_id)
end
