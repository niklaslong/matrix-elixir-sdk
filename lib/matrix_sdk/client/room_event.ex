defmodule MatrixSDK.Client.RoomEvent do
  @moduledoc """
  Convenience functions for building room events.
  """

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
  def message(room_id, type, content, transaction_id),
    do: %__MODULE__{
      content: content(type, content),
      type: "m.room.message",
      room_id: room_id,
      transaction_id: transaction_id
    }

  defp content(:text, %{body: body, formatted_body: formatted_body, format: format}) do
    %{
      msgtype: "m.text",
      body: body,
      formatted_body: formatted_body,
      format: format
    }
  end

  defp content(:text, %{body: body, formatted_body: formatted_body}) do
    content(:text, %{body: body, formatted_body: formatted_body, format: "org.matrix.custom.html"})
  end

  defp content(:text, %{body: body}), do: %{msgtype: "m.text", body: body}

  defp content(:text, body), do: %{msgtype: "m.text", body: body}

  defp content(:notice, content) do
    content(:text, content)
    |> Map.update!(:msgtype, fn _ -> "m.notice" end)
  end

  @file_optional_params [:filename, :info]

  defp content(:file, %{body: body, url: url} = content) do
    acc = %{msgtype: "m.file", body: body, url: url}

    Enum.reduce(content, acc, fn {param_name, value}, acc ->
      if Enum.member?(@file_optional_params, param_name) do
        Map.put(acc, param_name, value)
      else
        acc
      end
    end)
  end
end
