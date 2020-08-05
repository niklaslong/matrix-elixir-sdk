defmodule MatrixSDK.StateEvent do
  @enforce_keys [:content, :type, :room_id, :state_key]
  defstruct [:content, :type, :room_id, state_key: ""]

  def join_rules(room_id, body),
    do: %__MODULE__{
      content: %{join_rule: body},
      type: "m.room.join_rules",
      room_id: room_id,
      state_key: ""
    }
end
