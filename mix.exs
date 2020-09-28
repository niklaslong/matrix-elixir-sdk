defmodule MatrixSDK.MixProject do
  use Mix.Project

  def project do
    [
      app: :matrix_sdk,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [http_client: MatrixSDK.HTTPClient]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3"},
      {:mint, "~> 1.0"},
      {:castore, "~> 0.1.0"},
      {:jason, "~> 1.2"},
      {:mox, "~> 1.0.0", only: :test},
      {:bypass, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    A Matrix SDK for Elixir 
    """
  end

  defp docs do
    [
      main: "readme",
      name: "Matrix SDK",
      source_url: "https://github.com/niklaslong/matrix-elixir-sdk",
      extras: ["README.md"],
      groups_for_modules: [
        "Client-Server API": [
          MatrixSDK.Client.Request,
          MatrixSDK.Client.Auth,
          MatrixSDK.Client.RoomEvent,
          MatrixSDK.Client.StateEvent
        ]
      ]
    ]
  end

  defp package() do
    [
      maintainers: ["Niklas Long"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/niklaslong/matrix-elixir-sdk"}
    ]
  end
end
