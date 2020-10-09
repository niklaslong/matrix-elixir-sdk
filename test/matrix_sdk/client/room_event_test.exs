defmodule MatrixSDK.Client.RoomEventTest do
  use ExUnit.Case, async: true
  alias MatrixSDK.Client.RoomEvent

  doctest RoomEvent

  @text_based_tests [{:text, "m.text"}, {:notice, "m.notice"}]

  @text_based_tests
  |> Enum.each(fn {type, msgtype} ->
    describe "message/4 with #{msgtype} type" do
      test "text only content with inlined body" do
        room_id = "!someroom:matrix.org"
        type = unquote(type)
        content = "Fire! Fire! Fire!"
        transaction_id = "transaction_id"

        room_event = RoomEvent.message(room_id, type, content, transaction_id)

        assert room_event.content.msgtype == unquote(msgtype)
        assert room_event.content.body == content
        assert room_event.type == "m.room.message"
        assert room_event.room_id == room_id
        assert room_event.transaction_id == transaction_id
      end

      test "text only content with full fledged keys" do
        room_id = "!someroom:matrix.org"
        type = unquote(type)
        content = %{body: "Fire! Fire! Fire!"}
        transaction_id = "transaction_id"

        room_event = RoomEvent.message(room_id, type, content, transaction_id)

        assert room_event.content.msgtype == unquote(msgtype)
        assert room_event.content.body == content.body
        assert room_event.type == "m.room.message"
        assert room_event.room_id == room_id
        assert room_event.transaction_id == transaction_id
      end

      test "formatted body content" do
        room_id = "!someroom:matrix.org"
        type = unquote(type)
        content = %{body: "Fire! Fire! Fire!", formatted_body: "<b>Fire!</b>Fire!<b>Fire!</b>"}
        transaction_id = "transaction_id"

        room_event = RoomEvent.message(room_id, type, content, transaction_id)

        assert room_event.content.msgtype == unquote(msgtype)
        assert room_event.content.body == content.body
        assert room_event.content.formatted_body == content.formatted_body
        assert room_event.content.format == "org.matrix.custom.html"
        assert room_event.type == "m.room.message"
        assert room_event.room_id == room_id
        assert room_event.transaction_id == transaction_id
      end

      test "formatted body content with custom format" do
        room_id = "!someroom:matrix.org"
        type = unquote(type)

        content = %{
          body: "Fire! Fire! Fire!",
          formatted_body: "<b>Fire!</b>Fire!<b>Fire!</b>",
          format: "matrix_sdk.format"
        }

        transaction_id = "transaction_id"

        room_event = RoomEvent.message(room_id, type, content, transaction_id)

        assert room_event.content.msgtype == unquote(msgtype)
        assert room_event.content.body == content.body
        assert room_event.content.formatted_body == content.formatted_body
        assert room_event.content.format == content.format
        assert room_event.type == "m.room.message"
        assert room_event.room_id == room_id
        assert room_event.transaction_id == transaction_id
      end
    end
  end)

  describe "message/4 with m.file type" do
    test "file is unencrypted with required only keys" do
      room_id = "!someroom:matrix.org"
      type = :file

      content = %{
        body: "Some file description",
        url: "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe"
      }

      transaction_id = "transaction_id"

      room_event = RoomEvent.message(room_id, type, content, transaction_id)

      assert room_event.content.msgtype == "m.file"
      assert room_event.content.body == content.body
      assert room_event.content.url == content.url
      assert room_event.type == "m.room.message"
      assert room_event.room_id == room_id
      assert room_event.transaction_id == transaction_id
    end

    test "file is unencrypted with supported optional fields" do
      room_id = "!someroom:matrix.org"
      type = :file

      content = %{
        body: "Some file description",
        url: "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe",
        filename: "some_name.zip",
        info: %{mimetype: "application/zip"}
      }

      transaction_id = "transaction_id"

      room_event = RoomEvent.message(room_id, type, content, transaction_id)

      assert room_event.content.msgtype == "m.file"
      assert room_event.content.body == content.body
      assert room_event.content.url == content.url
      assert room_event.content.filename == content.filename
      assert room_event.content.info == content.info
      assert room_event.type == "m.room.message"
      assert room_event.room_id == room_id
      assert room_event.transaction_id == transaction_id
    end

    test "file is unencrypted with unsupported fields" do
      room_id = "!someroom:matrix.org"
      type = :file

      content = %{
        body: "Some file description",
        url: "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe",
        filename: "some_name.zip",
        info: %{mimetype: "application/zip"},
        unsupported_field: "some_value"
      }

      transaction_id = "transaction_id"

      room_event = RoomEvent.message(room_id, type, content, transaction_id)

      assert room_event.content.msgtype == "m.file"
      assert room_event.content.body == content.body
      assert room_event.content.url == content.url
      assert room_event.content.filename == content.filename
      assert room_event.content.info == content.info
      refute Map.has_key?(room_event.content, :unsupported_field)
      assert room_event.type == "m.room.message"
      assert room_event.room_id == room_id
      assert room_event.transaction_id == transaction_id
    end
  end
end
