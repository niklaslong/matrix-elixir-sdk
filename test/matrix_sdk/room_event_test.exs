defmodule MatrixSDK.RoomEventTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.RoomEvent

  describe "message/3 with type:" do
    test "m.text" do
      room_id = "!someroom:matrix.org"
      type = :text
      body = "Fire! Fire! Fire!"

      room_event = RoomEvent.message(room_id, type, body)

      assert room_event.content.msgtype == "m.text"
      assert room_event.content.body == body
      assert room_event.type == "m.room.message"
      assert room_event.room_id == room_id
      assert is_binary(room_event.transaction_id)
    end
  end
end
