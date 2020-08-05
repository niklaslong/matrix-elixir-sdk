defmodule MatrixSDK.RoomEvent do
  @enforce_keys [:content, :type, :transaction_id, :room_id]
  defstruct [:content, :type, :room_id, :transaction_id]

  @type t :: %__MODULE__{}

  @doc """
  Returns a `RoomEvent` struct of type `m.room.message`. 

  ## Example

      MatrixSDK.RoomEvent.message("!someroom:matrix.org", :text, "Fire! Fire! Fire!")
  """
  def message(room_id, type, body),
    do: %__MODULE__{
      content: content(type, body),
      type: "m.room.message",
      room_id: room_id,
      transaction_id: transaction_id()
    }

  defp content(:text, body), do: %{msgtype: "m.text", body: body}

  # In future use incrementing number (startup timestamp + increment), however this does imply state...
  defp transaction_id(),
    do:
      100
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64()
end
