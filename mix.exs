defmodule UmbrellaStage.Mixfile do
  use Mix.Project

  @github_url "https://github.com/iacobson/umbrella_stage"

  def project do
    [
      app: :umbrella_stage,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      source_url: @github_url,
      homepage_url: @github_url,
      description: description(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UmbrellaStage.Application, []}
    ]
  end

  def description do
    "Subscribes GenStage consumers to producers across ubmrella apps"
  end

  def package do
    [
      maintainers: ["Dorian Iacobescu"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github_url,
        "Blog Post" => "https://medium.com/@iacobson/latest",
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.12"}
    ]
  end
end
