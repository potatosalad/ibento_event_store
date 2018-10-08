defmodule Ibento.EventStore.Embedded do
  use Ecto.Schema

  embedded_schema do
    field(:data, :map)
  end
end
