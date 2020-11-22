defmodule MatrixSDK.API.Error do
  @moduledoc """
  Defines functions and types for parsing 4xx API responses.
  """

  @enforce_keys [:kind, :message, :status_code]
  defstruct [
    :kind,
    :message,
    :status_code,
    :soft_logout,
    :retry_after_ms,
    :room_version,
    :admin_contact
  ]

  @type t :: %__MODULE__{
          kind: binary,
          message: binary,
          status_code: integer,
          soft_logout: boolean | nil,
          retry_after_ms: integer | nil,
          room_version: binary | nil,
          admin_contact: binary | nil
        }

  @doc """
  Parses a response into an `Error` struct containing the Matrix error kind,
  the error message and the HTTP status code. Optionally it includes the
  `soft_logout`, `retry_after_ms`, `room_version` and `admin_contact` fields
  when applicable.
  """
  # TODO: the input type should be more precise, see HTTPClient.
  @spec for(any) :: t
  def for(response) do
    %__MODULE__{
      kind: response.body["errcode"],
      message: response.body["error"],
      status_code: response.status,
      soft_logout: response.body["soft_logout"],
      retry_after_ms: response.body["retry_after_ms"],
      room_version: response.body["room_version"],
      admin_contact: response.body["admin_contact"]
    }
  end
end
