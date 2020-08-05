defmodule MatrixSDK.StateEventTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.StateEvent

  describe "message/3 with type:" do
    test "m.text" do
      room_id = "!someroom:matrix.org"
      type = :join_rules
      body = "public"

      state_event = StateEvent.new(room_id, type, body)

      assert state_event.content == %{join_rule: body}
      assert state_event.type == "m.room.join_rules"
      assert state_event.room_id == room_id
      assert state_event.state_key == ""
    end
  end
end
