defmodule AspireTest do
  use ExUnit.Case, async: false
  import Mock
  doctest Aspire

  test "to_string can catch exceptions from :erlang.list_to_binary" do
    with_mock Aspire.Utils, [:passthrough], [list_to_binary: fn(_) -> throw("hello") end] do
      assert [] == Aspire.to_string([])
    end
    with_mock Aspire.Utils, [:passthrough], [list_to_binary: fn(_) -> exit(:kill) end] do
      assert [] == Aspire.to_string([])
    end
  end

end
