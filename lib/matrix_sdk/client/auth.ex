defmodule MatrixSDK.Client.Auth do
  @moduledoc """
  Convenience functions for building authentication types.

  Note: an identifier is only used when doing a password login.
  """

  @type dummy :: %{type: binary}
  @type token :: %{type: binary, token: binary}
  @type password :: %{type: binary, identifier: id, password: binary}
  @type recaptcha :: %{type: binary, response: binary}
  @type thirdparty :: %{type: binary, threepidCreds: [sid: binary, client_secret: binary]}

  @type id_user :: %{type: binary, user: binary}
  @type id_thirdparty :: %{type: binary, medium: binary, address: binary}
  @type id_phone :: %{type: binary, country: binary, phone: binary}

  @type t :: dummy | token | password | recaptcha | thirdparty
  @type id :: id_user | id_thirdparty | id_phone

  @spec login_dummy() :: dummy
  def login_dummy(), do: %{type: "m.login.dummy"}

  @spec login_token(binary) :: token
  def login_token(token), do: %{type: "m.login.token", token: token}

  @spec login_recaptcha(binary) :: recaptcha
  def login_recaptcha(response), do: %{type: "m.login.recaptcha", response: response}

  @spec login_email_identity(binary, binary) :: thirdparty
  def login_email_identity(sid, client_secret),
    do: %{type: "m.login.email.identity", threepidCreds: [three_pid_creds(sid, client_secret)]}

  @spec login_msisdn(binary, binary) :: thirdparty
  def login_msisdn(sid, client_secret),
    do: %{type: "m.login.msisdn", threepidCreds: [three_pid_creds(sid, client_secret)]}

  @spec three_pid_creds(binary, binary) :: map
  defp three_pid_creds(sid, client_secret), do: %{sid: sid, client_secret: client_secret}

  @spec login_password(id, binary) :: password
  defp login_password(identifier, password),
    do: %{type: "m.login.password", identifier: identifier, password: password}

  @spec login_user(binary, binary) :: password
  def login_user(user, password),
    do:
      user
      |> id_user()
      |> login_password(password)

  @spec login_3pid(binary, binary, binary) :: password
  def login_3pid(medium, address, password),
    do:
      medium
      |> id_thirdparty(address)
      |> login_password(password)

  @spec login_phone(binary, binary, binary) :: password
  def login_phone(country, phone, password),
    do:
      country
      |> id_phone(phone)
      |> login_password(password)

  @spec id_user(binary) :: id_user
  defp id_user(user), do: %{type: "m.id.user", user: user}

  @spec id_thirdparty(binary, binary) :: id_thirdparty
  defp id_thirdparty(medium, address),
    do: %{type: "m.id.thirdparty", medium: medium, address: address}

  @spec id_phone(binary, binary) :: id_phone
  defp id_phone(country, phone),
    do: %{type: "m.id.phone", country: country, phone: phone}

  @spec put_session(map, binary) :: map
  def put_session(map, session_id), do: Map.put(map, :session, session_id)
end
