defmodule MatrixSDK.StateEvent do
  @enforce_keys [:content, :type, :room_id, :state_key]
  defstruct [:content, :type, :room_id, state_key: ""]

  @type t :: %__MODULE__{}

  @doc """
  Returns a `StateEvent` struct of type `m.room.join_rules`. 

  ## Example

      MatrixSDK.StateEvent.join_rules("!someroom:matrix.org". "public")
  """
  def join_rules(room_id, body),
    do: %__MODULE__{
      content: %{join_rule: body},
      type: "m.room.join_rules",
      room_id: room_id,
      state_key: ""
    }
end
