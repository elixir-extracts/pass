defmodule Passport.Mixfile do
  use Mix.Project

  def project do
    [app: :passport,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
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

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:plug, "~> 1.0"},
      {:ecto, "~> 1.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test}
    ]
  end
end
