defmodule ExPoppy.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_poppy,
      version: "0.1.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "~> 0.32.1", runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
