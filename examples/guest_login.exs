alias MatrixSDK.API
alias MatrixSDK.API.Request

defmodule Example do
  @base_server "https://matrix.org"

  require Logger

  def main() do
    # Note if the matrix.org server is unresponsive, there will be a timeout error
    # from the HTTP client.
    Logger.info("Running guest login example...")
    Logger.info("Registering guest user...")

    # This will register a guest account with the matrix.org homeserver and returns
    # a token to be used for subsequent reqeuests.
    response =
      @base_server
      |> Request.register_guest()
      |> API.do_request()

    Logger.debug("Response:")
    IO.inspect(response.body)

    token = response.body["access_token"]
    room = "#elixirsdktest:matrix.org"

    Logger.info("Joining the #{inspect(room)} room...")
    {:ok, room_id} = join_room(room, token)

    response =
      @base_server
      |> Request.room_messages(token, room, "", "f")
      |> API.do_request()

    IO.inspect(response, label: "response")

    Logger.info("Starting sync for room: #{inspect(room)}...")
    IO.puts(" (press ctrl-c to stop)")

    sync_loop(room_id, token)
  end

  defp join_room(room, token) do
    # Hack: passing the lambda to itslef to be able to use recursion.
    response =
      @base_server
      |> Request.join_room(token, room)
      |> API.do_request()

    case response do
      %MatrixSDK.API.Error{} = error ->
        IO.puts(error.message)
        IO.gets("press enter to continue:")
        join_room(room, token)

      _ ->
        {:ok, response.body["room_id"]}
    end
  end

  defp sync_loop(room_id, token, since \\ nil) do
    params = if since == nil, do: %{}, else: %{since: since, timeout: 1000}

    response =
      @base_server
      |> Request.sync(token, params)
      |> API.do_request()

    room_events = response.body["rooms"]["join"][room_id]

    if room_events do
      IO.puts("Stuff happened in the room:")
      IO.inspect(room_events, label: "room_events")
    end

    sync_loop(room_id, token, response.body["next_batch"])
  end
end

Example.main()
