defmodule MatrixSDK.API.ErrorTest do
  use ExUnit.Case, async: true

  alias MatrixSDK.API.Error
  alias Tesla

  describe "for/1:" do
    test "parses a 4xx HTTP response into an Error" do
      response = %Tesla.Env{
        status: 401,
        body: %{
          # Testing all the fields here, in reality not all of these will be
          # present at the same time.
          "errcode" => "M_UNKNOWN_TOKEN",
          "error" => "Invalid macaroon passed.",
          "soft_logout" => false,
          "retry_after_ms" => 2000,
          "room_version" => "1",
          "admin_contact" => "mailto:server.admin@example.org"
        }
      }

      error = Error.for(response)

      assert error.kind == response.body["errcode"]
      assert error.message == response.body["error"]
      assert error.status_code == response.status
      assert error.soft_logout == response.body["soft_logout"]
      assert error.retry_after_ms == response.body["retry_after_ms"]
      assert error.room_version == response.body["room_version"]
      assert error.admin_contact == response.body["admin_contact"]
    end
  end
end
