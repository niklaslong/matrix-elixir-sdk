defmodule MatrixSDK.Client.RoomEventTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.Client.RoomEvent

  doctest RoomEvent

  describe "message/3 with type:" do
    test "m.text" do
      room_id = "!someroom:matrix.org"
      type = :text
      body = "Fire! Fire! Fire!"
      transaction_id = "transaction_id"

      room_event = RoomEvent.message(room_id, type, body, transaction_id)

      assert room_event.content.msgtype == "m.text"
      assert room_event.content.body == body
      assert room_event.type == "m.room.message"
      assert room_event.room_id == room_id
      assert room_event.transaction_id == transaction_id
    end
  end
end
