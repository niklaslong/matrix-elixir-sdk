defmodule NeobeamTest do
  use ExUnit.Case
  doctest Neobeam

  test "greets the world" do
    assert Neobeam.hello() == :world
  end
end
