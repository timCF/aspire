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

  test "to_atom can catch exceptions from String.to_existing_atom" do
    with_mock Aspire.Utils, [:passthrough], [string_to_existing_atom: fn(_) -> throw("hello") end] do
      assert "hello_world" == Aspire.to_atom("hello_world")
    end
    with_mock Aspire.Utils, [:passthrough], [string_to_existing_atom: fn(_) -> exit(:kill) end] do
      assert "hello_world" == Aspire.to_atom("hello_world")
    end
  end

end
