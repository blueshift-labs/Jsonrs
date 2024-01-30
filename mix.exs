defmodule Jsonrs.MixProject do
  use Mix.Project

  @version "0.3.4"

  def project do
    [
      app: :jsonrs,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/blueshift-labs/jsonrs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~> 1.0 or ~> 2.0", optional: true},
      {:rustler_precompiled, "~> 0.7.0"},
      {:rustler, "~> 0.30.0", optional: true, runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    A fully-featured and performant JSON library powered by Rust
    """
  end

  defp package() do
    [
      maintainers: ["Ben Haney", "Yang Ou"],
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/blueshift-labs/jsonrs"},
      files: [
        "lib",
        "mix.exs",
        "README*",
        "native/jsonrs/src",
        "native/jsonrs/.cargo",
        "native/jsonrs/README*",
        "native/jsonrs/Cargo*",
        "checksum-*.exs"
      ]
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Jsonrs",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/jsonrs",
      source_url: "https://github.com/blueshift-labs/jsonrs",
      extras: [
        "README.md"
      ]
    ]
  end
end
