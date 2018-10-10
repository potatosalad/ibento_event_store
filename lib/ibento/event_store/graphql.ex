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

  def connection(module, opts) when is_list(opts) do
    as_stream = Keyword.get(opts, :as_stream, false)
    causation = Keyword.get(opts, :causation, nil)
    correlation = Keyword.get(opts, :correlation, nil)
    debug = Keyword.get(opts, :debug, false)
    debug_streams = Keyword.get(opts, :debug_streams, false)
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, nil)
    order = Keyword.get(opts, :order, [])
    resolve = Keyword.get(opts, :resolve, nil)
    stop_limit = Keyword.get(opts, :stop_limit, 1000)
    streams = Keyword.get(opts, :streams, ["$all"])

    resolve =
      if is_nil(resolve) do
        &__MODULE__.resolve/1
      else
        resolve
      end

    connection =
      struct(module,
        causation: causation,
        correlation: correlation,
        debug: debug,
        debug_streams: debug_streams,
        limit: limit,
        offset: offset,
        order: order,
        resolve: resolve,
        stop_limit: stop_limit,
        streams: streams
      )

    if as_stream == true do
      module.to_stream(connection)
    else
      connection
    end
  end

  def resolve(value) do
    case read_event_output(value) do
      {:ok, event = %Ibento.EventStore.Event{type: type}} ->
        case resolve_event_type(type) do
          {:ok, module} ->
            case Ibento.EventStore.Event.load(module, event) do
              {:ok, event} ->
                event

              :error ->
                event
            end

          :error ->
            event
        end

      :error ->
        value
    end
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

  @impl Ibento.EventStore
  @spec read_event_output(output :: term()) :: {:ok, Ibento.EventStore.Event.t()} | :error | {:error, term()}
  def read_event_output(event = %Ibento.EventStore.Event{}) do
    {:ok, event}
  end

  def read_event_output(
        output = %{
          "eventId" => event_id,
          "type" => type,
          "correlation" => correlation,
          "causation" => causation,
          "data" => data,
          "metadata" => metadata,
          "debug" => debug
        }
      )
      when is_binary(event_id) and is_binary(type) and is_binary(data) and is_boolean(debug) do
    cursor = Map.get(output, "cursor", nil)
    streams = Map.get(output, "streams", nil)
    inserted_at = Map.get(output, "insertedAt", nil)

    case Jason.decode(data) do
      {:ok, data} when is_map(data) ->
        case Jason.decode(metadata) do
          {:ok, metadata} when is_map(metadata) ->
            event = %Ibento.EventStore.Event{
              id: event_id,
              type: type,
              correlation: correlation,
              causation: causation,
              data: data,
              metadata: metadata,
              debug: debug,
              inserted_at: try_load_datetime(inserted_at),
              cursor: cursor,
              streams: streams
            }

            read_event_output(event)

          error = {:error, _} ->
            error
        end

      error = {:error, _} ->
        error
    end
  end

  def read_event_output(_) do
    :error
  end

  @impl Ibento.EventStore
  def resolve_event_type(type) when is_binary(type) do
    result =
      try do
        atom = String.to_existing_atom(type)
        {:ok, atom}
      catch
        _, _ ->
          :error
      end

    case result do
      {:ok, module} when is_atom(module) ->
        if Code.ensure_loaded?(module) do
          {:ok, module}
        else
          :error
        end

      :error ->
        :error
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

  @doc false
  defp try_load_datetime(value = %DateTime{}) do
    value
  end

  defp try_load_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime = %DateTime{}, _offset} ->
        datetime

      {:error, _reason} ->
        value
    end
  end

  defp try_load_datetime(nil) do
    nil
  end
end
