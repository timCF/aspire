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
        |> __MODULE__.to_float
        |> case do
          float when is_float(float) ->
            float
            |> __MODULE__.to_integer
            |> case do
              integer when is_integer(integer) -> integer
              ^float -> binary
            end
          ^binary ->
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
          ^binary -> list
        end
    end
  end

  def to_integer(some), do: some

  @doc """

  Safe conversion to float type.

  ## Examples

    ```
    iex> Aspire.to_float(0)
    0.0
    iex> Aspire.to_float(123)
    123.0
    iex> Aspire.to_float(-123)
    -123.0

    iex> Aspire.to_float("0")
    0.0
    iex> Aspire.to_float("123")
    123.0
    iex> Aspire.to_float("-123")
    -123.0
    iex> Aspire.to_float("123.123")
    123.123
    iex> Aspire.to_float("-123.12300")
    -123.123
    iex> Aspire.to_float("hello")
    "hello"
    iex> Aspire.to_float("123.")
    "123."
    iex> Aspire.to_float(".123")
    ".123"
    iex> Aspire.to_float("123.1ww23")
    "123.1ww23"

    iex> Aspire.to_float(:"0")
    0.0
    iex> Aspire.to_float(:"123")
    123.0
    iex> Aspire.to_float(:"-123")
    -123.0
    iex> Aspire.to_float(:"123.123")
    123.123
    iex> Aspire.to_float(:"-123.12300")
    -123.123
    iex> Aspire.to_float(:hello)
    :hello
    iex> Aspire.to_float(:"123.")
    :"123."
    iex> Aspire.to_float(:".123")
    :".123"
    iex> Aspire.to_float(:"123.1ww23")
    :"123.1ww23"
    iex> Aspire.to_float(nil)
    nil

    iex> Aspire.to_float('0')
    0.0
    iex> Aspire.to_float('123')
    123.0
    iex> Aspire.to_float('-123')
    -123.0
    iex> Aspire.to_float('123.123')
    123.123
    iex> Aspire.to_float('-123.12300')
    -123.123
    iex> Aspire.to_float('hello')
    'hello'
    iex> Aspire.to_float('123.')
    '123.'
    iex> Aspire.to_float('.123')
    '.123'
    iex> Aspire.to_float('123.1ww23')
    '123.1ww23'
    iex> Aspire.to_float([])
    []
    iex> Aspire.to_float([12345, 12345])
    [12345, 12345]

    iex> Aspire.to_float(%{hello: "world"})
    %{hello: "world"}
    ```

  """

  def to_float(integer) when is_integer(integer) do
    integer / 1
  end

  def to_float(binary) when is_binary(binary) do
    binary
    |> Float.parse
    |> case do
      {float, ""} -> float
      _ -> binary
    end
  end

  def to_float(atom) when is_atom(atom) do
    atom
    |> Atom.to_string
    |> __MODULE__.to_float
    |> case do
      float when is_float(float) -> float
      _ -> atom
    end
  end

  def to_float(list) when is_list(list) do
    list
    |> __MODULE__.to_string
    |> case do
      list when is_list(list) ->
        list
      binary when is_binary(binary) ->
        binary
        |> __MODULE__.to_float
        |> case do
          float when is_float(float) -> float
          ^binary -> list
        end
    end
  end

  def to_float(some), do: some

  @doc """

  Safe conversion to number type.

  ## Examples

    ```
    iex> Aspire.to_number("0.0")
    0
    iex> Aspire.to_number("123.0")
    123
    iex> Aspire.to_number("-123.0")
    -123
    iex> Aspire.to_number("123.123")
    123.123
    iex> Aspire.to_number("-123.123")
    -123.123
    iex> Aspire.to_number("hello")
    "hello"
    ```

  """

  def to_number(some) do
    case to_integer(some) do
      integer when is_integer(integer) -> integer
      ^some -> to_float(some)
    end
  end

  @doc """

    Safe conversion to atom type.

    ## Examples

      ```
      iex> Aspire.to_atom("erlang")
      :erlang
      iex> Aspire.to_atom("hello_world")
      "hello_world"

      iex> Aspire.to_atom('erlang')
      :erlang
      iex> Aspire.to_atom('hello_world')
      'hello_world'
      iex> Aspire.to_atom(123.123)
      123.123

      iex> Aspire.to_atom(%{hello: "world"})
      %{hello: "world"}
      ```
  """

  def to_atom(binary) when is_binary(binary) do
    try do
      Aspire.Utils.string_to_existing_atom(binary)
    rescue
      _ -> binary
    catch
      _    -> binary
      _, _ -> binary
    end
  end

  def to_atom(some) when is_number(some) or is_list(some) do
    some
    |> __MODULE__.to_string
    |> case do
      ^some ->
        some
      binary when is_binary(binary) ->
        binary
        |> __MODULE__.to_atom
        |> case do
          atom when is_atom(atom) -> atom
          ^binary -> some
        end
    end
  end

  def to_atom(some), do: some

  @doc """

  Safe conversion to map type.

  ## Examples

    ```
    iex> Aspire.to_map(%Aspire{decimals: 5})
    %{decimals: 5, compact: true}
    iex> Aspire.to_map([foo: 123, bar: 321])
    %{foo: 123, bar: 321}
    iex> Aspire.to_map([{"foo", 123}, {"bar", 321}])
    [{"foo", 123}, {"bar", 321}]
    iex> Aspire.to_map([123, 321])
    [123, 321]
    iex> Aspire.to_map("hello")
    "hello"
    ```

  """

  def to_map(struct = %_{}) do
    struct
    |> Map.from_struct
    |> Map.delete(:__meta__)
  end

  def to_map(list) when is_list(list) do
    list
    |> Keyword.keyword?
    |> case do
      true -> Enum.reduce(list, %{}, fn({k, v}, acc = %{}) -> Map.put(acc, k, v) end)
      false -> list
    end
  end

  def to_map(some), do: some

  @doc """

  Safe conversion to boolean type.

  ## Examples

    ```
    iex> Aspire.to_boolean(1)
    true
    iex> Aspire.to_boolean(0)
    false
    iex> Aspire.to_boolean(nil)
    false
    iex> Aspire.to_boolean(:undefined)
    false
    iex> Aspire.to_boolean("true")
    true
    iex> Aspire.to_boolean("false")
    false

    iex> Aspire.to_boolean(1.0)
    1.0
    iex> Aspire.to_boolean(2)
    2
    iex> Aspire.to_boolean("hello")
    "hello"
    ```

  """

  def to_boolean(1), do: true
  def to_boolean(0), do: false
  def to_boolean(nil), do: false
  def to_boolean(:undefined), do: false
  def to_boolean("true"), do: true
  def to_boolean("false"), do: false
  def to_boolean(some), do: some

  @doc """

    Safe conversion to list type.

    ## Examples

      ```
      iex> Aspire.to_list(%Aspire{decimals: 5}) |> Enum.sort
      [compact: true, decimals: 5]
      iex> Aspire.to_list(%{foo: 123, bar: 321}) |> Enum.sort
      [bar: 321, foo: 123]
      iex> Aspire.to_list("hello")
      'hello'
      iex> Aspire.to_list(123)
      123
      ```
  """

  def to_list(struct = %_{}) do
    struct
    |> __MODULE__.to_map
    |> __MODULE__.to_list
  end

  def to_list(map = %{}) do
    map
    |> Map.to_list
  end

  def to_list(binary) when is_binary(binary) do
    binary
    |> String.to_charlist
  end

  def to_list(some), do: some

end
