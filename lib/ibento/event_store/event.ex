defprotocol Ibento.EventStore.Event do
  @type streams() :: [binary()]
  @type long(event_data) :: %__MODULE__{
          id: Ibento.UUID.t(),
          type: binary(),
          correlation: nil | binary(),
          causation: nil | binary(),
          data: event_data,
          metadata: map(),
          debug: boolean(),
          cursor: nil | binary(),
          streams: nil | streams()
        }
  @type long() :: long(map() | struct())
  @type short(event_data) :: event_data | {event_data, streams()}
  @type short() :: short(struct())
  @type t(event_data) :: long(event_data) | short(event_data)
  @type t() :: t(struct())

  @enforce_keys [:data]
  defstruct id: nil,
            type: nil,
            correlation: nil,
            causation: nil,
            data: %{},
            metadata: %{},
            debug: false,
            cursor: nil,
            streams: []

  @fallback_to_any true

  @spec load(term(), t()) :: {:ok, t()} | :error | {:error, term()}
  def load(type, event)
end

defimpl Ibento.EventStore.Event, for: Any do
  def load(type, event = %Ibento.EventStore.Event{data: event_data}) when is_map(event_data) do
    case Ibento.EventStore.EventData.load(type, event_data) do
      {:ok, event_data} ->
        event = %Ibento.EventStore.Event{event | data: event_data}
        {:ok, event}

      :error ->
        :error

      error = {:error, _reason} ->
        error
    end
  end

  def load(_, _) do
    :error
  end
end
