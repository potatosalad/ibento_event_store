defmodule Ibento.Base32Crockford do
  defguardp is_iodata(i) when is_binary(i) or is_list(i)

  defmacrop to_binary(i) do
    quote do
      case unquote(i) do
        _ when is_binary(unquote(i)) ->
          unquote(i)

        _ when is_list(unquote(i)) ->
          :erlang.iolist_to_binary(unquote(i))
      end
    end
  end

  defmacrop lc_b32crockford_to_int(c) do
    quote do
      case unquote(c) do
        ?0 -> 0x00
        ?1 -> 0x01
        ?2 -> 0x02
        ?3 -> 0x03
        ?4 -> 0x04
        ?5 -> 0x05
        ?6 -> 0x06
        ?7 -> 0x07
        ?8 -> 0x08
        ?9 -> 0x09
        ?a -> 0x0A
        ?b -> 0x0B
        ?c -> 0x0C
        ?d -> 0x0D
        ?e -> 0x0E
        ?f -> 0x0F
        ?g -> 0x10
        ?h -> 0x11
        ?j -> 0x12
        ?k -> 0x13
        ?m -> 0x14
        ?n -> 0x15
        ?p -> 0x16
        ?q -> 0x17
        ?r -> 0x18
        ?s -> 0x19
        ?t -> 0x1A
        ?v -> 0x1B
        ?w -> 0x1C
        ?x -> 0x1D
        ?y -> 0x1E
        ?z -> 0x1F
      end
    end
  end

  defmacrop mc_b32crockford_to_int(c) do
    quote do
      case unquote(c) do
        ?0 -> 0x00
        ?1 -> 0x01
        ?2 -> 0x02
        ?3 -> 0x03
        ?4 -> 0x04
        ?5 -> 0x05
        ?6 -> 0x06
        ?7 -> 0x07
        ?8 -> 0x08
        ?9 -> 0x09
        ?a -> 0x0A
        ?b -> 0x0B
        ?c -> 0x0C
        ?d -> 0x0D
        ?e -> 0x0E
        ?f -> 0x0F
        ?g -> 0x10
        ?h -> 0x11
        ?j -> 0x12
        ?k -> 0x13
        ?m -> 0x14
        ?n -> 0x15
        ?p -> 0x16
        ?q -> 0x17
        ?r -> 0x18
        ?s -> 0x19
        ?t -> 0x1A
        ?v -> 0x1B
        ?w -> 0x1C
        ?x -> 0x1D
        ?y -> 0x1E
        ?z -> 0x1F
        ?A -> 0x0A
        ?B -> 0x0B
        ?C -> 0x0C
        ?D -> 0x0D
        ?E -> 0x0E
        ?F -> 0x0F
        ?G -> 0x10
        ?H -> 0x11
        ?J -> 0x12
        ?K -> 0x13
        ?M -> 0x14
        ?N -> 0x15
        ?P -> 0x16
        ?Q -> 0x17
        ?R -> 0x18
        ?S -> 0x19
        ?T -> 0x1A
        ?V -> 0x1B
        ?W -> 0x1C
        ?X -> 0x1D
        ?Y -> 0x1E
        ?Z -> 0x1F
      end
    end
  end

  defmacrop uc_b32crockford_to_int(c) do
    quote do
      case unquote(c) do
        ?0 -> 0x00
        ?1 -> 0x01
        ?2 -> 0x02
        ?3 -> 0x03
        ?4 -> 0x04
        ?5 -> 0x05
        ?6 -> 0x06
        ?7 -> 0x07
        ?8 -> 0x08
        ?9 -> 0x09
        ?A -> 0x0A
        ?B -> 0x0B
        ?C -> 0x0C
        ?D -> 0x0D
        ?E -> 0x0E
        ?F -> 0x0F
        ?G -> 0x10
        ?H -> 0x11
        ?J -> 0x12
        ?K -> 0x13
        ?M -> 0x14
        ?N -> 0x15
        ?P -> 0x16
        ?Q -> 0x17
        ?R -> 0x18
        ?S -> 0x19
        ?T -> 0x1A
        ?V -> 0x1B
        ?W -> 0x1C
        ?X -> 0x1D
        ?Y -> 0x1E
        ?Z -> 0x1F
      end
    end
  end

  defmacrop lc_int_to_b32crockford(c) do
    quote do
      case unquote(c) do
        0x00 -> ?0
        0x01 -> ?1
        0x02 -> ?2
        0x03 -> ?3
        0x04 -> ?4
        0x05 -> ?5
        0x06 -> ?6
        0x07 -> ?7
        0x08 -> ?8
        0x09 -> ?9
        0x0A -> ?a
        0x0B -> ?b
        0x0C -> ?c
        0x0D -> ?d
        0x0E -> ?e
        0x0F -> ?f
        0x10 -> ?g
        0x11 -> ?h
        0x12 -> ?j
        0x13 -> ?k
        0x14 -> ?m
        0x15 -> ?n
        0x16 -> ?p
        0x17 -> ?q
        0x18 -> ?r
        0x19 -> ?s
        0x1A -> ?t
        0x1B -> ?v
        0x1C -> ?w
        0x1D -> ?x
        0x1E -> ?y
        0x1F -> ?z
      end
    end
  end

  defmacrop uc_int_to_b32crockford(c) do
    quote do
      case unquote(c) do
        0x00 -> ?0
        0x01 -> ?1
        0x02 -> ?2
        0x03 -> ?3
        0x04 -> ?4
        0x05 -> ?5
        0x06 -> ?6
        0x07 -> ?7
        0x08 -> ?8
        0x09 -> ?9
        0x0A -> ?A
        0x0B -> ?B
        0x0C -> ?C
        0x0D -> ?D
        0x0E -> ?E
        0x0F -> ?F
        0x10 -> ?G
        0x11 -> ?H
        0x12 -> ?J
        0x13 -> ?K
        0x14 -> ?M
        0x15 -> ?N
        0x16 -> ?P
        0x17 -> ?Q
        0x18 -> ?R
        0x19 -> ?S
        0x1A -> ?T
        0x1B -> ?V
        0x1C -> ?W
        0x1D -> ?X
        0x1E -> ?Y
        0x1F -> ?Z
      end
    end
  end

  def decode(input) when is_iodata(input) do
    decode(input, %{})
  end

  def decode(input, opts) when is_iodata(input) and is_map(opts) do
    try do
      decode!(input, opts)
    catch
      _, _ ->
        :error
    else
      output when is_binary(output) ->
        {:ok, output}
    end
  end

  def decode(input, opts) when is_iodata(input) and is_list(opts) do
    decode(input, :maps.from_list(opts))
  end

  def decode!(input) when is_iodata(input) do
    decode!(input, %{})
  end

  def decode!([], %{}) do
    <<>>
  end

  def decode!(<<>>, %{}) do
    <<>>
  end

  def decode!(input, opts) when is_iodata(input) and is_map(opts) do
    ccase = Map.get(opts, :case, :mixed)
    padding = Map.get(opts, :padding, nil)
    size = :erlang.iolist_size(input)

    offset =
      case padding do
        _ when (padding == false or is_nil(padding)) and size <= 8 ->
          0

        _ when (padding == false or is_nil(padding)) and rem(size, 8) === 0 ->
          size - 8

        _ when (padding == false or is_nil(padding)) and rem(size, 8) !== 0 ->
          size - rem(size, 8)

        _ when (padding == true or is_nil(padding)) and size >= 8 ->
          size - 8

        _ ->
          :erlang.error({:badarg, [input, opts]})
      end

    <<head0::binary-size(offset), tail0::bitstring()>> = to_binary(input)

    tail1 =
      case padding do
        false ->
          case tail0 do
            <<t0::binary-size(1), t1::8>> ->
              {t0, t1, 2, 3}

            <<t0::binary-size(3), t1::8>> ->
              {t0, t1, 4, 1}

            <<t0::binary-size(4), t1::8>> ->
              {t0, t1, 1, 4}

            <<t0::binary-size(6), t1::8>> ->
              {t0, t1, 3, 2}

            <<>> ->
              <<>>

            _ ->
              :erlang.error({:badarg, [input, opts]})
          end

        nil ->
          case tail0 do
            <<t0::binary-size(1), t1::8, ?=, ?=, ?=, ?=, ?=, ?=>> ->
              {t0, t1, 2, 3}

            <<t0::binary-size(3), t1::8, ?=, ?=, ?=, ?=>> ->
              {t0, t1, 4, 1}

            <<t0::binary-size(4), t1::8, ?=, ?=, ?=>> ->
              {t0, t1, 1, 4}

            <<t0::binary-size(6), t1::8, ?=>> ->
              {t0, t1, 3, 2}

            <<t0::binary-size(1), t1::8>> ->
              {t0, t1, 2, 3}

            <<t0::binary-size(3), t1::8>> ->
              {t0, t1, 4, 1}

            <<t0::binary-size(4), t1::8>> ->
              {t0, t1, 1, 4}

            <<t0::binary-size(6), t1::8>> ->
              {t0, t1, 3, 2}

            <<t0::binary-size(8)>> ->
              t0

            <<>> ->
              <<>>
          end

        true ->
          case tail0 do
            <<t0::binary-size(1), t1::8, ?=, ?=, ?=, ?=, ?=, ?=>> ->
              {t0, t1, 2, 3}

            <<t0::binary-size(3), t1::8, ?=, ?=, ?=, ?=>> ->
              {t0, t1, 4, 1}

            <<t0::binary-size(4), t1::8, ?=, ?=, ?=>> ->
              {t0, t1, 1, 4}

            <<t0::binary-size(6), t1::8, ?=>> ->
              {t0, t1, 3, 2}

            _ ->
              :erlang.error({:badarg, [input, opts]})
          end
      end

    {head, tail} =
      case ccase do
        :lower ->
          h = for <<v <- head0>>, into: <<>>, do: <<lc_b32crockford_to_int(v)::5>>

          t =
            case tail1 do
              <<>> ->
                <<>>

              _ when is_binary(tail1) ->
                for <<v <- tail1>>, into: <<>>, do: <<lc_b32crockford_to_int(v)::5>>

              {tail2, last0, bitshift, bits} ->
                tail3 = for <<v <- tail2>>, into: <<>>, do: <<lc_b32crockford_to_int(v)::5>>
                last = :erlang.bsr(lc_b32crockford_to_int(last0), bitshift)
                <<tail3::bitstring(), last::size(bits)>>
            end

          {h, t}

        :mixed ->
          h = for <<v <- head0>>, into: <<>>, do: <<mc_b32crockford_to_int(v)::5>>

          t =
            case tail1 do
              <<>> ->
                <<>>

              _ when is_binary(tail1) ->
                for <<v <- tail1>>, into: <<>>, do: <<mc_b32crockford_to_int(v)::5>>

              {tail2, last0, bitshift, bits} ->
                tail3 = for <<v <- tail2>>, into: <<>>, do: <<mc_b32crockford_to_int(v)::5>>
                last = :erlang.bsr(mc_b32crockford_to_int(last0), bitshift)
                <<tail3::bitstring(), last::size(bits)>>
            end

          {h, t}

        :upper ->
          h = for <<v <- head0>>, into: <<>>, do: <<uc_b32crockford_to_int(v)::5>>

          t =
            case tail1 do
              <<>> ->
                <<>>

              _ when is_binary(tail1) ->
                for <<v <- tail1>>, into: <<>>, do: <<uc_b32crockford_to_int(v)::5>>

              {tail2, last0, bitshift, bits} ->
                tail3 = for <<v <- tail2>>, into: <<>>, do: <<uc_b32crockford_to_int(v)::5>>
                last = :erlang.bsr(uc_b32crockford_to_int(last0), bitshift)
                <<tail3::bitstring(), last::size(bits)>>
            end

          {h, t}

        _ ->
          :erlang.error({:badarg, [input, opts]})
      end

    <<head::bitstring(), tail::bitstring()>>
  end

  def decode!(input, opts) when is_iodata(input) and is_list(opts) do
    decode!(input, :maps.from_list(opts))
  end

  def encode(input) when is_iodata(input) do
    encode(input, %{})
  end

  def encode(input, opts) when is_iodata(input) and is_map(opts) do
    ccase = Map.get(opts, :case, :upper)
    padding = Map.get(opts, :padding, true)
    offset = 5 * div(:erlang.iolist_size(input) * 8, 5)
    <<head::bitstring-size(offset), tail::bitstring()>> = to_binary(input)

    case ccase do
      :lower when is_boolean(padding) ->
        h = for <<v::5 <- head>>, into: <<>>, do: <<lc_int_to_b32crockford(v)>>

        {t, pad} =
          case tail do
            <<v::1>> -> {<<lc_int_to_b32crockford(:erlang.bsl(v, 4))>>, 4}
            <<v::2>> -> {<<lc_int_to_b32crockford(:erlang.bsl(v, 3))>>, 1}
            <<v::3>> -> {<<lc_int_to_b32crockford(:erlang.bsl(v, 2))>>, 6}
            <<v::4>> -> {<<lc_int_to_b32crockford(:erlang.bsl(v, 1))>>, 3}
            <<>> -> {<<>>, 0}
          end

        case padding do
          true ->
            <<h::binary(), t::binary(), :binary.copy(<<?=>>, pad)::binary()>>

          false ->
            <<h::binary(), t::binary()>>
        end

      :upper when is_boolean(padding) ->
        h = for <<v::5 <- head>>, into: <<>>, do: <<uc_int_to_b32crockford(v)>>

        {t, pad} =
          case tail do
            <<v::1>> -> {<<uc_int_to_b32crockford(:erlang.bsl(v, 4))>>, 4}
            <<v::2>> -> {<<uc_int_to_b32crockford(:erlang.bsl(v, 3))>>, 1}
            <<v::3>> -> {<<uc_int_to_b32crockford(:erlang.bsl(v, 2))>>, 6}
            <<v::4>> -> {<<uc_int_to_b32crockford(:erlang.bsl(v, 1))>>, 3}
            <<>> -> {<<>>, 0}
          end

        case padding do
          true ->
            <<h::binary(), t::binary(), :binary.copy(<<?=>>, pad)::binary()>>

          false ->
            <<h::binary(), t::binary()>>
        end

      _ ->
        :erlang.error({:badarg, [input, opts]})
    end
  end

  def encode(input, opts) when is_iodata(input) and is_list(opts) do
    encode(input, :maps.from_list(opts))
  end
end
