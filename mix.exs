defmodule Mnesiam.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :mnesiam,
      version: "0.2.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      docs: [
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mnesia]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: [:dev], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:credo, "~> 0.9", only: [:dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    Mnesiam is a Mnesia db manager for painless Mnesia clustering.
    """
  end

  defp package do
    [
      name: :mnesiam,
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Mustafa Turan"],
      licenses: ["Apache License 2.0"],
      links: %{"GitHub" => "https://github.com/mustafaturan/mnesiam"}
    ]
  end
end
