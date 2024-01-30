defprotocol Jsonrs.Encoder do
  @moduledoc """
  Protocol controlling how a value is encoded to JSON.

  By default, structs are encoded as maps without the `:__struct__` key. If this
  is sufficient for your use, you don't need to implement this protocol.

  When implementing an encoding function, the goal is to turn your value into
  something already capable of being encoded.

  ## Example

  An implementation of this protocol for `Decimal` might look something like

      defimpl Jsonrs.Encoder, for: Decimal do
        def encode(value) do
          Decimal.to_string(value)
        end
      end

  Which will cause the Decimal to be encoded as its string representation

  """

  @fallback_to_any true

  @doc """
  Converts `value` to a JSON-encodable type.
  """
  def encode(value)
end

defimpl Jsonrs.Encoder, for: Atom do
  def encode(nil), do: nil
  def encode(true), do: true
  def encode(false), do: false
  def encode(atom), do: Atom.to_string(atom)
end

defimpl Jsonrs.Encoder, for: Integer do
  def encode(integer), do: integer
end

defimpl Jsonrs.Encoder, for: Float do
  def encode(float), do: float
end

defimpl Jsonrs.Encoder, for: BitString do
  def encode(binary) when is_binary(binary), do: binary

  def encode(bitstring) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: bitstring,
      description: "cannot encode a bitstring to JSON"
  end
end

defimpl Jsonrs.Encoder, for: MapSet do
  def encode(set) do
    MapSet.to_list(set) |> Jsonrs.Encoder.encode()
  end
end

defimpl Jsonrs.Encoder, for: Map do
  def encode(map), do: :maps.map(fn _, v -> Jsonrs.Encoder.encode(v) end, map)
end

defimpl Jsonrs.Encoder, for: List do
  def encode(list) do
    cond do
      Keyword.keyword?(list) ->
        list |> Enum.into(%{}) |> Jsonrs.Encoder.encode()

      true ->
        Enum.map(list, &Jsonrs.Encoder.encode/1)
    end
  end
end

defimpl Jsonrs.Encoder, for: [Date, Time, NaiveDateTime, DateTime] do
  def encode(d), do: d |> @for.to_iso8601()
end

defimpl Jsonrs.Encoder, for: URI do
  def encode(uri), do: URI.to_string(uri)
end

defimpl Jsonrs.Encoder, for: Decimal do
  def encode(value) do
    decimal = Decimal
    decimal.to_string(value)
  end
end

defimpl Jsonrs.Encoder, for: Any do
  defmacro __deriving__(module, struct, opts) do
    fields = fields_to_encode(struct, opts)

    quote do
      defimpl Jsonrs.Encoder, for: unquote(module) do
        def encode(any) do
          any
          |> Map.from_struct()
          |> Map.take(unquote(fields))
          |> Jsonrs.Encoder.encode()
        end
      end
    end
  end

  def encode(%_{} = struct) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: struct,
      description: """
      Jsonrs.Encoder protocol must always be explicitly implemented.

      If you own the struct, you can derive the implementation specifying \
      which fields should be encoded to JSON:

          @derive {Jsonrs.Encoder, only: [....]}
          defstruct ...

      It is also possible to encode all fields, although this should be \
      used carefully to avoid accidentally leaking private information \
      when new fields are added:

          @derive Jsonrs.Encoder
          defstruct ...

      Finally, if you don't own the struct you want to encode to JSON, \
      you may use Protocol.derive/3 placed outside of any module:

          Protocol.derive(Jsonrs.Encoder, NameOfTheStruct, only: [...])
          Protocol.derive(Jsonrs.Encoder, NameOfTheStruct)
      """
  end

  def encode(value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: value,
      description: "Jsonrs.Encoder protocol must always be explicitly implemented"
  end

  defp fields_to_encode(struct, opts) do
    fields = Map.keys(struct)

    cond do
      only = Keyword.get(opts, :only) ->
        case only -- fields do
          [] ->
            only

          error_keys ->
            raise ArgumentError,
                  "`:only` specified keys (#{inspect(error_keys)}) that are not defined in defstruct: " <>
                    "#{inspect(fields -- [:__struct__])}"
        end

      except = Keyword.get(opts, :except) ->
        case except -- fields do
          [] ->
            fields -- [:__struct__ | except]

          error_keys ->
            raise ArgumentError,
                  "`:except` specified keys (#{inspect(error_keys)}) that are not defined in defstruct: " <>
                    "#{inspect(fields -- [:__struct__])}"
        end

      true ->
        fields -- [:__struct__]
    end
  end
end
