defmodule Ibento.EventStore do
  @callback put_event(input :: term()) :: {:ok, term()} | {:error, term()}
  @callback put_events(input :: term()) :: {:ok, term()} | {:error, term()}
  @callback put_event_input(input :: term()) :: {:ok, term()} | :error | {:error, term()}
  @callback put_events_input(input :: term()) :: {:ok, term()} | :error | {:error, term()}
  @callback read_event_output(output :: term()) :: {:ok, Ibento.EventStore.Event.t()} | :error | {:error, term()}
  @callback resolve_event_type(type :: binary()) :: {:ok, module()} | :error | {:error, term()}

  @optional_callbacks put_event: 1,
                      put_events: 1,
                      put_event_input: 1,
                      put_events_input: 1,
                      read_event_output: 1,
                      resolve_event_type: 1
end
