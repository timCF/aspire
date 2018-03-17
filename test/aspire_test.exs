defmodule AspireTest do
  use ExUnit.Case
  doctest Aspire

  test "greets the world" do
    assert Aspire.hello() == :world
  end
end
