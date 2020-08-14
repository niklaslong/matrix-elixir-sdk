defmodule MatrixSDK.Client.RoomEvent do
  @enforce_keys [:content, :type, :transaction_id, :room_id]
  defstruct [:content, :type, :room_id, :transaction_id]

  @type t :: %__MODULE__{}

  @doc """
  Returns a `RoomEvent` struct of type `m.room.message`. 

  ## Example

      iex> MatrixSDK.Client.RoomEvent.message("!someroom:matrix.org", :text, "Fire! Fire! Fire!", "transaction_id")
      %MatrixSDK.Client.RoomEvent{
        content: %{body: "Fire! Fire! Fire!", msgtype: "m.text"},
        type: "m.room.message",
        room_id: "!someroom:matrix.org",
        transaction_id: "transaction_id"
      }

  """
  def message(room_id, type, body, transaction_id),
    do: %__MODULE__{
      content: content(type, body),
      type: "m.room.message",
      room_id: room_id,
      transaction_id: transaction_id
    }

  defp content(:text, body), do: %{msgtype: "m.text", body: body}
end
