defmodule MatrixSDK.Auth do
  @moduledoc """
  Convenience functions for building authentication types.
  """

  @type dummy :: %{type: binary}
  @type token :: %{type: binary, token: binary}
  @type password :: %{type: binary, identifier: id, password: binary}

  @type id_user :: %{type: binary, user: binary}
  @type id_thirdparty :: %{type: binary, medium: binary, address: binary}
  @type id_phone :: %{type: binary, country: binary, phone: binary}

  @type t :: dummy | token | password
  @type id :: id_user | id_thirdparty | id_phone

  def login_dummy(), do: %{type: "m.login.dummy"}
  def login_token(token), do: %{type: "m.login.token", token: token}

  def login_password(identifier, password),
    do: %{type: "m.login.password", identifier: identifier, password: password}

  def id_user(user), do: %{type: "m.id.user", user: user}

  def id_thirdparty(medium, address),
    do: %{type: "m.id.thirdparty", medium: medium, address: address}

  def id_phone(country, phone),
    do: %{type: "m.id.phone", country: country, phone: phone}

  def put_session(map, session_id), do: Map.put(map, :session, session_id)
end
