alias MatrixSDK.Client
alias MatrixSDK.Client.Request

require Logger

# Note if the matrix.org server is unresponsive, there will be a timeout error
# from the HTTP client. 
Logger.info("Running guest login example...")
Logger.info("Registering guest user...")

url = "https://matrix.org"

#  This will register a guest account with the matrix.org homeserver and returns
# a token to be used for subsequent reqeuests.
{:ok, response} =
  url
  |> Request.register_guest()
  |> Client.do_request()

Logger.debug("Response:")
IO.inspect(response.body)

token = response.body["access_token"]
room = "#elixirsdktest:matrix.org"

# Hack: passing the lambda to itslef to be able to use recursion. 
join_room = fn join_room ->
  {:ok, response} =
    url
    |> Request.join_room(token, room)
    |> Client.do_request()

  if response.body["errcode"] do
    IO.gets(
      "Please accept the matrix.org terms and conditions by opening this link in the browser: #{
        inspect(response.body["consent_uri"])
      }, once this is done, press enter to continue:"
    )

    join_room.(join_room)
  else
    Logger.debug("Response:")
    IO.inspect(response.body)
  end
end

Logger.info("Joining #{inspect(room)} room...")
join_room.(join_room)

Logger.info("Starting sync for room #{inspect(room)}...")

{:ok, response} =
  url
  |> Request.sync(token)
  |> Client.do_request()

Logger.debug("Response:")
IO.inspect(response.body)
