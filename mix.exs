defmodule Passport.Mixfile do
  use Mix.Project

  def project do
    [app: :passport,
     version: "0.1.1",
     description: "A simple authentication manager for Plug applications.",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  # Configuration for the OTP application
  # Type "mix help compile.app" for more information
  def application do
    # Specify applications based on environment
    [applications: applications(Mix.env)]
  end


  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:prod)
  defp elixirc_paths(_),     do: ["lib"]

  defp applications(:test) do
    applications(:prod) ++ [:logger, :ecto, :postgrex]
  end
  defp applications(_) do
    [:crypto, :plug]
  end

  # Type "mix help deps" for examples and options
  defp deps do
    [
      {:plug, "~> 1.0"},
      {:json_web_token, "~> 0.2"},

      {:ecto, "~> 1.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp package do
    [
      # Don't want to include "priv" which is included by default
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Brad Lindsay"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/elixir-extracts/passport"}
    ]
  end
end
