defmodule MatrixSDK.Client.StateEvent do
  @moduledoc """
  Convenience functions for building state events.
  """

  @enforce_keys [:content, :type, :room_id, :state_key]
  defstruct [:content, :type, :room_id, state_key: ""]

  @type t :: %__MODULE__{}

  @doc """
  Returns a `StateEvent` struct of type `m.room.join_rules`.

  ## Example

      MatrixSDK.Client.StateEvent.join_rules("!someroom:matrix.org". "public")
  """
  def join_rules(room_id, body),
    do: %__MODULE__{
      content: %{join_rule: body},
      type: "m.room.join_rules",
      room_id: room_id,
      state_key: ""
    }

  @doc """
  Returns a `StateEvent` struct of type `m.room.topic`.

  ## Example

      MatrixSDK.Client.StateEvent.topic("!someroom:matrix.org". "Example room topic")
  """
  def topic(room_id, body),
    do: %__MODULE__{
      content: %{topic: body},
      type: "m.room.topic",
      room_id: room_id,
      state_key: ""
    }
end
