defprotocol Ibento.EventStore.EventList do
  @type t() :: %__MODULE__{
          entries: [Ibento.EventStore.EventEntry.t()]
        }

  defstruct entries: []

  @fallback_to_any true

  @spec cast(term) :: {:ok, t()} | :error | {:error, Ecto.Changeset.t()}
  def cast(value)
end

defimpl Enumerable, for: Ibento.EventStore.EventList do
  def count(%@for{entries: entries}) do
    {:ok, length(entries)}
  end

  def member?(%@for{entries: entries}, element) do
    {:ok, Enum.member?(entries, element)}
  end

  def reduce(%@for{entries: entries}, acc, fun) do
    reduce_list(entries, acc, fun)
  end

  def slice(%@for{entries: entries}) do
    {:ok, length(entries), &Enumerable.List.slice(entries, &1, &2)}
  end

  @doc false
  defp reduce_list(_list, {:halt, acc}, _fun), do: {:halted, acc}
  defp reduce_list(list, {:suspend, acc}, fun), do: {:suspended, acc, &reduce_list(list, &1, fun)}
  defp reduce_list([], {:cont, acc}, _fun), do: {:done, acc}
  defp reduce_list([head | tail], {:cont, acc}, fun), do: reduce_list(tail, fun.(head, acc), fun)
end

defimpl Ibento.EventStore.EventList, for: Any do
  def cast(value) do
    case Ibento.EventStore.EventEntry.cast(value) do
      {:ok, event_entry = %Ibento.EventStore.EventEntry{}} ->
        event_list = %Ibento.EventStore.EventList{entries: [event_entry]}
        {:ok, event_list}

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end
end

defimpl Ibento.EventStore.EventList, for: Ibento.EventStore.EventList do
  def cast(event_list = %@for{}) do
    {:ok, event_list}
  end
end

defimpl Ibento.EventStore.EventList, for: List do
  def cast(list) when is_list(list) do
    cast_event_entries(list, [])
  end

  @doc false
  defp cast_event_entries([event | events], event_entries) do
    case Ibento.EventStore.EventEntry.cast(event) do
      {:ok, event_entry = %Ibento.EventStore.EventEntry{}} ->
        cast_event_entries(events, [event_entry | event_entries])

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end

  defp cast_event_entries([], event_entries) do
    event_list = %Ibento.EventStore.EventList{entries: :lists.reverse(event_entries)}
    {:ok, event_list}
  end
end
