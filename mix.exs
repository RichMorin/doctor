defmodule Doctor.MixProject do
  use Mix.Project

  def project do
    [
      app: :doctor,
      version: "0.7.0",
      elixir: "~> 1.7",
      name: "Doctor",
      source_url: "https://github.com/akoutmos/doctor",
      homepage_url: "https://hex.pm/packages/doctor",
      description: "Simple utility to create documentation coverage reports",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/sample_files"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      name: "doctor",
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/akoutmos/doctor"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~> 1.7"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
