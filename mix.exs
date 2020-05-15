defmodule MatrixSDK.MixProject do
  use Mix.Project

  def project do
    [
      app: :matrix_sdk,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MatrixSDK.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3"},
      {:hackney, "~> 1.15.2"},
      {:jason, "~> 1.2"},
      {:mox, "~> 0.5.2", only: :test}
    ]
  end
end
