defprotocol Ibento.EventStore.EventEntry do
  @type streams() :: [binary()]
  @type long(event_data) :: %__MODULE__{
          id: nil | Ibento.ULID.t(),
          ingest_id: nil | Ibento.ULID.t(),
          vclock: nil | non_neg_integer(),
          type: nil | binary(),
          correlation: nil | binary(),
          causation: nil | binary(),
          data: event_data,
          metadata: map(),
          debug: boolean(),
          streams: streams()
        }
  @type long() :: long(map() | struct())
  @type short(event_data) :: event_data | {event_data, streams()}
  @type short() :: short(struct())
  @type t(event_data) :: long(event_data) | short(event_data)
  @type t() :: t(struct())

  @enforce_keys [:data]
  defstruct id: nil,
            ingest_id: nil,
            vclock: nil,
            type: nil,
            correlation: nil,
            causation: nil,
            data: %{},
            metadata: %{},
            debug: false,
            streams: []

  @fallback_to_any true

  @spec cast(term()) :: {:ok, t()} | :error | {:error, Ecto.Changeset.t()}
  def cast(value)
end

defimpl Ibento.EventStore.EventEntry, for: Any do
  def cast(event_data = %{__struct__: _}) do
    # We're dealing with EventData, not an EventEntry.
    event_entry = %Ibento.EventStore.EventEntry{data: event_data}
    Ibento.EventStore.EventEntry.cast(event_entry)
  end

  def cast({event_data = %{__struct__: _}, opts}) when is_list(opts) do
    # We're dealing with {EventData, Options}, not an EventEntry.
    event_entry = cast_options(event_data, opts)
    Ibento.EventStore.EventEntry.cast(event_entry)
  end

  def cast(event_data = {module, params}) when is_atom(module) and is_map(params) do
    # We're dealing with {Module, Params}, not an EventEntry.
    event_entry = %Ibento.EventStore.EventEntry{data: event_data}
    Ibento.EventStore.EventEntry.cast(event_entry)
  end

  def cast({module, params, opts}) when is_atom(module) and is_map(params) and is_list(opts) do
    # We're dealing with {Module, Params, Options}, not an EventEntry.
    event_data = {module, params}
    event_entry = cast_options(event_data, opts)
    Ibento.EventStore.EventEntry.cast(event_entry)
  end

  def cast(_) do
    :error
  end

  @doc false
  defp cast_options(event_data, opts) when is_list(opts) do
    event_entry = %Ibento.EventStore.EventEntry{data: event_data}
    cast_options!(opts, event_entry)
  end

  @doc false
  defp cast_options!([{key, value} | rest], acc) do
    new_acc =
      case key do
        _ when is_binary(value) and key in [:event_id, :ingest_id, :type, :correlation, :causation] ->
          %{acc | key => value}
        _ when is_integer(value) and key in [:vclock] ->
          %{acc | key => value}
        _ when is_nil(value) and key in [:event_id, :ingest_id, :vclock, :type, :correlation, :causation] ->
          %{acc | key => value}
        _ when is_map(value) and key in [:metadata] ->
          %{acc | key => value}
        _ when is_boolean(value) and key in [:debug] ->
          %{acc | key => value}
        _ when is_list(value) and key in [:streams] ->
          %{acc | key => value}
        _ ->
          raise(ArgumentError, "bad option {key, value} for #{inspect({key, value})}")
      end

    cast_options!(rest, new_acc)
  end

  defp cast_options!([], acc) do
    acc
  end
end

defimpl Ibento.EventStore.EventEntry, for: Ibento.EventStore.EventEntry do
  def cast(event_entry = %@for{type: type, data: data, streams: streams})
      when is_binary(type) and is_map(data) and is_list(streams) do
    # Already resolved (hopefully).
    {:ok, event_entry}
  end

  def cast(event_entry = %@for{type: nil, data: data, streams: streams})
      when ((is_map(data) and map_size(data) > 0) or (is_tuple(data) and tuple_size(data) == 2)) and is_list(streams) do
    case Ibento.EventStore.EventData.cast(data) do
      {:ok, event_data} ->
        case Ibento.EventStore.EventData.type(data) do
          {:ok, type} ->
            event_entry = %@for{event_entry | type: type, data: event_data}
            {:ok, event_entry}

          :error ->
            :error
        end

      {:continue, data = %{__struct__: _}} ->
        event_entry = %@for{event_entry | data: data}
        cast(event_entry)

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end

  def cast(_) do
    :error
  end
end
