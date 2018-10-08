defmodule Ibento.ULID do
  use Bitwise

  def binallocate(size) when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    binallocate(:os.system_time(:millisecond), size)
  end

  def binallocate(timestamp, size)
      when is_integer(timestamp) and timestamp >= 0 and is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    random = random_capacity(size)
    bingenerate(timestamp, random)
  end

  def allocate(size) when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    allocate(:os.system_time(:millisecond), size)
  end

  def allocate(timestamp, size)
      when is_integer(timestamp) and timestamp >= 0 and is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    random = random_capacity(size)
    generate(timestamp, random)
  end

  def bingenerate(timestamp \\ :os.system_time(:millisecond), random \\ :crypto.strong_rand_bytes(10))

  def bingenerate(timestamp, random)
      when is_integer(timestamp) and timestamp >= 0 and is_binary(random) and byte_size(random) == 10 do
    <<timestamp::unsigned-big-integer-unit(1)-size(48), random::binary-size(10)>>
  end

  def generate(timestamp \\ :os.system_time(:millisecond), random \\ :crypto.strong_rand_bytes(10))

  def generate(timestamp, random) when is_integer(timestamp) and timestamp >= 0 and is_binary(random) and byte_size(random) == 10 do
    Ibento.UUID.string!(bingenerate(timestamp, random))
  end

  def decode(<<timestamp::unsigned-big-integer-unit(1)-size(48), random::binary-size(10)>>) do
    {:ok, {timestamp, random}}
  end

  def decode(uuid) when is_binary(uuid) do
    case Ibento.UUID.binary(uuid) do
      {:ok, binary} ->
        decode(binary)

      :error ->
        :error
    end
  end

  def decode(_) do
    :error
  end

  def binnext(uuid) do
    with {:ok, {timestamp, <<x::unsigned-big-integer-unit(1)-size(80)>>}} <- decode(uuid),
         y when y <= 0xFFFFFFFFFFFFFFFFFFFF <- x + 1 do
      {:ok, bingenerate(timestamp, <<y::unsigned-big-integer-unit(1)-size(80)>>)}
    else
      _ ->
        :error
    end
  end

  def next(uuid) do
    with {:ok, {timestamp, <<x::unsigned-big-integer-unit(1)-size(80)>>}} <- decode(uuid),
         y when y <= 0xFFFFFFFFFFFFFFFFFFFF <- x + 1 do
      {:ok, generate(timestamp, <<y::unsigned-big-integer-unit(1)-size(80)>>)}
    else
      _ ->
        :error
    end
  end

  def random_capacity(size) when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    random_capacity(:crypto.strong_rand_bytes(10), size)
  end

  def random_capacity(random = <<x::unsigned-big-integer-unit(1)-size(80)>>, size)
      when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    if 0xFFFFFFFFFFFFFFFFFFFF - x >= size do
      random
    else
      bits = :erlang.round(:math.ceil(:math.log2(size)))
      y = x >>> bits <<< bits
      <<y::unsigned-big-integer-unit(1)-size(80)>>
    end
  end

  def binstream(size) when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    binstream(:os.system_time(:millisecond), size)
  end

  def binstream(timestamp, size)
      when is_integer(timestamp) and timestamp >= 0 and is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    Stream.resource(fn -> {binallocate(timestamp, size), 0, size} end, &binstream_next_fun/1, &stream_after_fun/1)
  end

  @doc false
  defp binstream_next_fun({acc, x, max}) do
    with y when y <= max <- x + 1,
         {:ok, uuid} <- binnext(acc) do
      {[uuid], {uuid, y, max}}
    else
      _ ->
        {:halt, nil}
    end
  end

  def stream(size) when is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    stream(:os.system_time(:millisecond), size)
  end

  def stream(timestamp, size)
      when is_integer(timestamp) and timestamp >= 0 and is_integer(size) and size >= 0 and size <= 0xFFFFFFFFFF do
    Stream.resource(fn -> {allocate(timestamp, size), 0, size} end, &stream_next_fun/1, &stream_after_fun/1)
  end

  @doc false
  defp stream_next_fun({acc, x, max}) do
    with y when y <= max <- x + 1,
         {:ok, uuid} <- next(acc) do
      {[uuid], {uuid, y, max}}
    else
      _ ->
        {:halt, nil}
    end
  end

  @doc false
  defp stream_after_fun(_) do
    :ok
  end
end
