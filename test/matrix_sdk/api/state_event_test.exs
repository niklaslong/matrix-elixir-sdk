defmodule MatrixSDK.API.StateEventTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.API.StateEvent

  doctest StateEvent

  test "join_rules/2" do
    room_id = "!someroom:matrix.org"
    body = "public"

    state_event = StateEvent.join_rules(room_id, body)

    assert state_event.content == %{join_rule: body}
    assert state_event.type == "m.room.join_rules"
    assert state_event.room_id == room_id
    assert state_event.state_key == ""
  end

  test "topic/2" do
    room_id = "!someroom:matrix.org"
    body = "Some room topic"

    state_event = StateEvent.topic(room_id, body)

    assert state_event.content == %{topic: body}
    assert state_event.type == "m.room.topic"
    assert state_event.room_id == room_id
    assert state_event.state_key == ""
  end
end
