defmodule MatrixSDK.StateEvent do
  @enforce_keys [:content, :type, :room_id, :state_key]
  defstruct [:content, :type, :room_id, state_key: ""]

  def new(room_id, type, body),
    do: %__MODULE__{
      content: content(type, body),
      type: type(type),
      room_id: room_id,
      state_key: ""
    }

  defp content(:join_rules, body), do: %{join_rule: body}

  defp type(:join_rules), do: "m.room.join_rules"
end
