defmodule Aspire do
  @moduledoc """

  Aspire functions are trivial.
  Each function performs type conversion if it is 100% safe.
  Else it returns first argument as is.

  """

  defstruct [
    decimals: nil,
    compact: true,
  ]

  @doc """

  Safe conversion to string (binary) type.
  Second argument is %Aspire{} structure with options

    - decimals: non negative integer, required if first argument is float
    - compact: boolean, optional, default true

  ## Examples

      ```
      iex> Aspire.to_string(:hello)
      "hello"
      iex> Aspire.to_string(MyApp.Mymodule)
      "Elixir.MyApp.Mymodule"
      iex> Aspire.to_string(nil)
      "nil"
      iex> Aspire.to_string(:undefined)
      "undefined"
      iex> Aspire.to_string(false)
      "false"

      iex> Aspire.to_string(0)
      "0"
      iex> Aspire.to_string(123)
      "123"
      iex> Aspire.to_string(-123)
      "-123"

      iex> Aspire.to_string(0.00000, %Aspire{decimals: 8})
      "0.0"
      iex> Aspire.to_string(1.230000, %Aspire{decimals: 8})
      "1.23"
      iex> Aspire.to_string(1.230000, %Aspire{decimals: 8, compact: false})
      "1.23000000"
      iex> Aspire.to_string(1.23e5, %Aspire{decimals: 8})
      "123000.0"
      iex> Aspire.to_string(1.23)
      1.23

      iex> Aspire.to_string('hello world')
      "hello world"
      iex> Aspire.to_string([])
      ""
      iex> Aspire.to_string([12345, 12345, 12345])
      [12345, 12345, 12345]
      iex> Aspire.to_string([hello: "world"])
      [hello: "world"]

      iex> Aspire.to_string(%{hello: "world"})
      %{hello: "world"}
      ```

  """

  def to_string(some, params \\ %__MODULE__{})

  def to_string(atom, %__MODULE__{}) when is_atom(atom) do
    atom
    |> Atom.to_string
  end

  def to_string(integer, %__MODULE__{}) when is_integer(integer) do
    integer
    |> Integer.to_string
  end

  def to_string(float, %__MODULE__{decimals: decimals, compact: compact})
                  when
                    is_float(float) and
                    is_integer(decimals) and
                    (decimals >= 0) and
                    is_boolean(compact)
                  do
    opts =
      case compact do
        true -> [:compact]
        false -> []
      end
      |> Kernel.++([decimals: decimals])

    float
    |> :erlang.float_to_binary(opts)
  end

  def to_string(list, %__MODULE__{}) when is_list(list) do
    try do
      Aspire.Utils.list_to_binary(list)
    rescue
      _ -> list
    catch
      _    -> list
      _, _ -> list
    end
  end

  def to_string(some, _), do: some

  @doc """

  Safe conversion to integer type.

  ## Examples

      ```
      iex> Aspire.to_integer("0")
      0
      iex> Aspire.to_integer("123")
      123
      iex> Aspire.to_integer("-123")
      -123

      iex> Aspire.to_integer("0.0")
      0
      iex> Aspire.to_integer("123.0")
      123
      iex> Aspire.to_integer("-123.0")
      -123
      iex> Aspire.to_integer("123.1")
      "123.1"
      iex> Aspire.to_integer("hello")
      "hello"

      iex> Aspire.to_integer(0.0)
      0
      iex> Aspire.to_integer(123.0)
      123
      iex> Aspire.to_integer(-123.0)
      -123
      iex> Aspire.to_integer(123.1)
      123.1

      iex> Aspire.to_integer(:"0")
      0
      iex> Aspire.to_integer(:"123")
      123
      iex> Aspire.to_integer(:"-123")
      -123

      iex> Aspire.to_integer(:"0.0")
      0
      iex> Aspire.to_integer(:"123.0")
      123
      iex> Aspire.to_integer(:"-123.0")
      -123
      iex> Aspire.to_integer(:"123.1")
      :"123.1"
      iex> Aspire.to_integer(:hello)
      :hello
      iex> Aspire.to_integer(nil)
      nil

      iex> Aspire.to_integer('0')
      0
      iex> Aspire.to_integer('123')
      123
      iex> Aspire.to_integer('-123')
      -123

      iex> Aspire.to_integer('0.0')
      0
      iex> Aspire.to_integer('123.0')
      123
      iex> Aspire.to_integer('-123.0')
      -123
      iex> Aspire.to_integer('123.1')
      '123.1'
      iex> Aspire.to_integer('hello')
      'hello'

      iex> Aspire.to_integer([])
      []
      iex> Aspire.to_integer([12345, 12345, 12345])
      [12345, 12345, 12345]

      iex> Aspire.to_integer(%{hello: "world"})
      %{hello: "world"}
      ```

  """

  def to_integer(binary) when is_binary(binary) do
    binary
    |> Integer.parse
    |> case do
      {integer, ""} ->
        integer
      _ ->
        binary
        |> Float.parse
        |> case do
          {float, ""} ->
            float
            |> __MODULE__.to_integer
            |> case do
              integer when is_integer(integer) -> integer
              _ -> binary
            end
          _ ->
            binary
         end
    end
  end

  def to_integer(float) when is_float(float) do
    float
    |> round
    |> case do
      integer when (float == integer) -> integer
      _ -> float
    end
  end

  def to_integer(atom) when is_atom(atom) do
    atom
    |> Atom.to_string
    |> __MODULE__.to_integer
    |> case do
      integer when is_integer(integer) -> integer
      _ -> atom
    end
  end

  def to_integer(list) when is_list(list) do
    list
    |> __MODULE__.to_string
    |> case do
      list when is_list(list) ->
        list
      binary when is_binary(binary) ->
        binary
        |> to_integer
        |> case do
          integer when is_integer(integer) -> integer
          _ -> list
        end
    end
  end

  def to_integer(some), do: some

end
