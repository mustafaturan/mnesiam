defmodule Mnesiam.Mixfile do
  use Mix.Project

  def project do
    [app: :mnesiam,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     description: description(),
     package: package(),
     docs: [extras: ["README.md"]],
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :mnesia],
     mod: {Mnesiam.Application, []}]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
     {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
     {:credo, "~> 0.7.3", only: :dev}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    Mnesiam is a Mnesia db manager for painless Mnesia clustering.
    """
  end

  defp package do
    [name: :mnesiam,
     files: ["lib", "mix.exs", "README.md"],
     maintainers: ["Mustafa Turan"],
     licenses: ["Apache License 2.0"],
     links: %{"GitHub" => "https://github.com/mustafaturan/mnesiam"}]
  end
end
