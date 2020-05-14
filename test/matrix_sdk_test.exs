defmodule MatrixSDKTest do
  use ExUnit.Case
  doctest MatrixSDK

  test "greets the world" do
    assert MatrixSDK.hello() == :world
  end
end
