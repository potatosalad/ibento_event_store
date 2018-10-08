defmodule Ibento.EventStore do
  @callback put_event(input :: term()) :: {:ok, term()} | {:error, term(), term(), term()}
  @callback put_events(input :: term()) :: {:ok, term()} | {:error, term(), term(), term()}
  @callback put_event_input(input :: term()) :: {:ok, term()} | :error | {:error, Ecto.Changeset.t()}
  @callback put_events_input(input :: term()) :: {:ok, term()} | :error | {:error, Ecto.Changeset.t()}

  @optional_callbacks put_event: 1, put_events: 1, put_event_input: 1, put_events_input: 1
end
