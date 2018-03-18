defmodule Aspire.Utils do

  @moduledoc """
  This module is only for inner usage.
  """

  @doc """

  Wrapper around standard &:erlang.list_to_binary/1

  ## Examples

    ```
    iex> Aspire.Utils.list_to_binary('hello')
    "hello"
    iex> Aspire.Utils.list_to_binary([])
    ""
    ```

  """

  def list_to_binary(some) do
    :erlang.list_to_binary(some)
  end

end
