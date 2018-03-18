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

  @doc """

  Wrapper around standard &String.to_existing_atom/1

  ## Examples

    ```
    iex> Aspire.Utils.string_to_existing_atom("erlang")
    :erlang
    ```
  """

  def string_to_existing_atom(binary) do
    String.to_existing_atom(binary)
  end

end
