defmodule ExPoppy.MixProject do
  use Mix.Project

  @version "0.2.0"
  @repo_url "https://github.com/hashlookup/ex_poppy"

  def project do
    [
      app: :ex_poppy,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: "NIF binding for the poppy bloom filter library using Rustler"
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
      {:rustler, ">= 0.0.0", runtime: false, optional: true},
      {:rustler_precompiled, "~> 0.6"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "native/ex_poppy/Cargo.toml",
        "native/ex_poppy/Cargo.lock",
        "native/ex_poppy/src",
        "native/ex_poppy/.cargo",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["gallypette"],
      licenses: ["BSD-3-Clause"],
      links: %{
        "GitHub" => @repo_url,
        "Poppy bloom filter library explained" =>
          "https://www.misp-project.org/2024/03/25/Poppy-a-new-bloom-filter-format-and-project.html/",
        "Original Poppy rust library" => "https://github.com/hashlookup/poppy/",
        "Hashlookup" => "https://hashlookup.io"
      }
    ]
  end

  defp docs do
    [
      main: "ExPoppy",
      source_ref: "#{@version}",
      source_url: @repo_url
    ]
  end
end
