defmodule Ibento.EventStore.MixProject do
  use Mix.Project

  def project() do
    [
      app: :ibento_event_store,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "ibento_event_store",
      package: package(),
      source_url: "https://github.com/potatosalad/ibento_event_store"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:ecto, "~> 2.2"},
      {:jason, "~> 1.1"}
    ]
  end

  defp description() do
    """
    Ibento.EventStore
    """
  end

  defp package() do
    [
      name: :ibento_event_store,
      files: [
        "CHANGELOG*",
        "lib",
        "LICENSE*",
        "mix.exs",
        "README*"
      ],
      licenses: ["Mozilla Public License Version 2.0"],
      links: %{
        "GitHub" => "https://github.com/potatosalad/ibento_event_store"
      },
      maintainers: ["Andrew Bennett"]
    ]
  end
end
