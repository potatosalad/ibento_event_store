defprotocol Ibento.EventStore.EventData do
  @type json_scalar() :: binary() | boolean() | float() | integer() | nil
  @type json_object() :: %{optional(binary()) => json_object() | json_scalar() | [json_object() | json_scalar()]}
  @type t() :: json_object()

  @fallback_to_any true

  @spec type(term()) :: {:ok, binary()} | :error | {:error, Ecto.Changeset.t()}
  def type(type)

  @spec cast(term()) :: {:ok, t()} | {:continue, struct()} | :error | {:error, Ecto.Changeset.t()}
  def cast(type)

  @spec load(term(), t()) :: {:ok, term()} | :error
  def load(type, data)
end

defimpl Ibento.EventStore.EventData, for: Atom do
  def type(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__struct__, 0) do
      type = struct(module)
      Ibento.EventStore.EventData.type(type)
    else
      :error
    end
  end

  def cast(_) do
    :error
  end

  def load(module, data) when is_atom(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__struct__, 0) do
      type = struct(module)
      Ibento.EventStore.EventData.load(type, data)
    else
      :error
    end
  end
end

defimpl Ibento.EventStore.EventData, for: Any do
  def type(_struct = %{__struct__: module}) when is_atom(module) do
    type = Atom.to_string(module)
    {:ok, type}
  end

  def type({module, params}) when is_atom(module) and is_map(params) do
    case cast({module, params}) do
      {:continue, struct} ->
        Ibento.EventStore.EventData.type(struct)

      :error ->
        :error

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end

  def cast(struct = %{__struct__: module}) when is_atom(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__schema__, 1) do
      embed = Ecto.Embedded.struct(Ibento.EventStore.Embedded, :data, cardinality: :one, related: module)

      case Ecto.Type.dump({:embed, embed}, struct) do
        {:ok, value} when is_map(value) ->
          with {:ok, value} <- Jason.encode(value),
               {:ok, value} <- Jason.decode(value) do
            {:ok, value}
          else
            _ ->
              :error
          end

        _ ->
          :error
      end
    else
      :error
    end
  end

  def cast({module, params}) when is_atom(module) and is_map(params) do
    if Code.ensure_loaded?(module) do
      cond do
        function_exported?(module, :__struct__, 0) and function_exported?(module, :changeset, 2) ->
          case module.changeset(struct(module), params) do
            changeset = %Ecto.Changeset{valid?: true} ->
              struct = Ecto.Changeset.apply_changes(changeset)
              {:continue, struct}

            changeset = %Ecto.Changeset{valid?: false} ->
              {:error, changeset}
          end

        function_exported?(module, :changeset, 1) ->
          case module.changeset(params) do
            changeset = %Ecto.Changeset{valid?: true} ->
              struct = Ecto.Changeset.apply_changes(changeset)
              {:continue, struct}

            changeset = %Ecto.Changeset{valid?: false} ->
              {:error, changeset}
          end

        true ->
          :error
      end
    else
      :error
    end
  end

  def load(%{__struct__: module}, data) when is_map(data) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__schema__, 1) do
      embed = Ecto.Embedded.struct(Ibento.EventStore.Embedded, :data, cardinality: :one, related: module)
      Ecto.Type.load({:embed, embed}, data)
    else
      :error
    end
  end
end
