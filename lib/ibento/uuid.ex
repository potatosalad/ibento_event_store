defmodule Ibento.UUID do
  @type uuid_base32crockford() :: <<_::208>>
  @type uuid_base64url() :: <<_::176>>
  @type uuid_binary() :: <<_::128>>
  @type uuid_md5() :: <<_::256>>
  @type uuid_string() :: <<_::288>>
  @type uuid() :: uuid_base32crockford() | uuid_base64url() | uuid_binary() | uuid_md5() | uuid_string()

  @type t() :: uuid()

  @spec base32crockford(uuid :: uuid() | term()) :: {:ok, uuid_base32crockford()} | :error
  def base32crockford(<<_::bitstring-size(128)>> = uuid) do
    {:ok, Ibento.Base32Crockford.encode(uuid, case: :upper, padding: false)}
  end

  def base32crockford(<<_::bitstring-size(208)>> = uuid) do
    {:ok, uuid}
  end

  def base32crockford(uuid) do
    with {:ok, uuid} <- binary(uuid) do
      base32crockford(uuid)
    end
  end

  @spec base64url(uuid :: uuid() | term()) :: {:ok, uuid_base64url()} | :error
  def base64url(<<_::bitstring-size(128)>> = uuid) do
    {:ok, Base.url_encode64(uuid, padding: false)}
  end

  def base64url(<<_::bitstring-size(176)>> = uuid) do
    {:ok, uuid}
  end

  def base64url(uuid) do
    with {:ok, uuid} <- binary(uuid) do
      base64url(uuid)
    end
  end

  @spec binary(uuid :: uuid() | term()) :: {:ok, uuid_binary()} | :error
  def binary(<<_::bitstring-size(128)>> = uuid) do
    {:ok, uuid}
  end

  def binary(<<_::bitstring-size(176)>> = uuid) do
    Base.url_decode64(uuid, padding: false)
  end

  def binary(<<_::bitstring-size(208)>> = uuid) do
    with {:ok, uuid} <- Ibento.Base32Crockford.decode(uuid, case: :mixed, padding: false) do
      binary(uuid)
    end
  end

  def binary(<<_::bitstring-size(256)>> = uuid) do
    with {:ok, uuid} <- Base.decode16(uuid, case: :mixed) do
      binary(uuid)
    end
  end

  def binary(<<_::bitstring-size(288)>> = uuid) do
    with {:ok, %Ecto.Query.Tagged{value: uuid}} <- Ecto.UUID.dump(uuid) do
      binary(uuid)
    end
  end

  def binary(_) do
    :error
  end

  @spec md5(uuid :: uuid() | term()) :: {:ok, uuid_md5()} | :error
  def md5(<<_::bitstring-size(128)>> = uuid) do
    {:ok, Base.encode16(uuid, case: :lower)}
  end

  def md5(<<_::bitstring-size(256)>> = uuid) do
    {:ok, uuid}
  end

  def md5(uuid) do
    with {:ok, uuid} <- binary(uuid) do
      md5(uuid)
    end
  end

  @spec string(uuid :: uuid() | term()) :: {:ok, uuid_string()} | :error
  def string(<<_::bitstring-size(128)>> = uuid) do
    Ecto.UUID.load(uuid)
  end

  def string(<<_::bitstring-size(288)>> = uuid) do
    Ecto.UUID.cast(uuid)
  end

  def string(uuid) do
    with {:ok, uuid} <- binary(uuid) do
      string(uuid)
    end
  end

  @spec base32crockford!(uuid :: uuid() | term()) :: uuid_base32crockford() | no_return()
  def base32crockford!(uuid) do
    case base32crockford(uuid) do
      {:ok, value} ->
        value

      _ ->
        raise ArgumentError
    end
  end

  @spec base64url!(uuid :: uuid() | term()) :: uuid_base64url() | no_return()
  def base64url!(uuid) do
    case base64url(uuid) do
      {:ok, value} ->
        value

      _ ->
        raise ArgumentError
    end
  end

  @spec binary!(uuid :: uuid() | term()) :: uuid_binary() | no_return()
  def binary!(uuid) do
    case binary(uuid) do
      {:ok, value} ->
        value

      _ ->
        raise ArgumentError
    end
  end

  @spec md5!(uuid :: uuid() | term()) :: uuid_md5() | no_return()
  def md5!(uuid) do
    case md5(uuid) do
      {:ok, value} ->
        value

      _ ->
        raise ArgumentError
    end
  end

  @spec string!(uuid :: uuid() | term()) :: uuid_string() | no_return()
  def string!(uuid) do
    case string(uuid) do
      {:ok, value} ->
        value

      _ ->
        raise ArgumentError
    end
  end
end
