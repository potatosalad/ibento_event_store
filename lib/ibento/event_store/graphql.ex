defmodule Ibento.EventStore.GraphQL do
  @behaviour Ibento.EventStore

  defmodule EventInput do
    @type t() :: %__MODULE__{query: binary(), variables: map()}
    @enforce_keys [:variables]
    defstruct query: ~S"""
              mutation PutEvent($input: PutEventInput!) {
                putEvent(input: $input) {
                  event {
                    id
                  }
                }
              }
              """,
              variables: nil
  end

  defmodule EventsInput do
    @type t() :: %__MODULE__{query: binary(), variables: map()}
    @enforce_keys [:variables]
    defstruct query: ~S"""
              mutation PutEvents($input: [PutEventInput]!) {
                putEvents(input: $input)
              }
              """,
              variables: nil
  end

  @impl Ibento.EventStore
  @spec put_event_input(event_entry :: Ibento.EventStore.EventEntry.t() | term()) ::
          {:ok, EventInput.t()} | :error | {:error, Ecto.Changeset.t()}
  def put_event_input(%Ibento.EventStore.EventEntry{
        id: id,
        type: type,
        correlation: correlation,
        causation: causation,
        data: data,
        metadata: metadata,
        debug: debug,
        streams: streams
      })
      when is_binary(type) and is_map(data) and is_boolean(debug) and is_list(streams) do
    event_id =
      case id do
        nil ->
          Ibento.ULID.generate()

        <<_::288>> ->
          id
      end

    metadata =
      case metadata do
        nil ->
          %{}

        %{} ->
          metadata
      end

    event_entry = %{
      "eventId" => event_id,
      "type" => type,
      "correlation" => correlation,
      "causation" => causation,
      "data" => Jason.encode!(data),
      "metadata" => Jason.encode!(metadata),
      "debug" => debug,
      "streams" => streams
    }

    input = %EventInput{variables: %{"input" => event_entry}}
    {:ok, input}
  end

  def put_event_input(value) do
    case Ibento.EventStore.EventEntry.cast(value) do
      {:ok, event_entry = %Ibento.EventStore.EventEntry{}} ->
        put_event_input(event_entry)

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end

  @impl Ibento.EventStore
  @spec put_events_input(event_entry :: Ibento.EventStore.EventList.t() | term()) ::
          {:ok, EventsInput.t()} | :error | {:error, Ecto.Changeset.t()}
  def put_events_input(event_list = %Ibento.EventStore.EventList{}) do
    event_id = Ibento.ULID.allocate(Enum.count(event_list))
    {_event_id, events} = Enum.reduce(event_list, {event_id, []}, &prepare_events_input/2)
    input = %EventsInput{variables: %{"input" => :lists.reverse(events)}}
    {:ok, input}
  end

  def put_events_input(value) do
    case Ibento.EventStore.EventList.cast(value) do
      {:ok, event_list = %Ibento.EventStore.EventList{}} ->
        put_events_input(event_list)

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end

  @doc false
  defp prepare_events_input(
         %Ibento.EventStore.EventEntry{
           id: id,
           type: type,
           correlation: correlation,
           causation: causation,
           data: data,
           metadata: metadata,
           debug: debug,
           streams: streams
         },
         {event_id, events}
       ) do
    streams = :lists.usort(streams)

    {id, event_id} =
      case id do
        nil ->
          case Ibento.ULID.next(event_id) do
            {:ok, next_event_id} ->
              {event_id, next_event_id}

            :error ->
              {event_id, event_id}
          end

        <<_::288>> ->
          {id, event_id}
      end

    event = %{
      "eventId" => id,
      "type" => type,
      "correlation" => correlation,
      "causation" => causation,
      "data" => Jason.encode!(data),
      "metadata" => Jason.encode!(metadata),
      "debug" => debug,
      "streams" => streams
    }

    events = [event | events]
    {event_id, events}
  end
end
