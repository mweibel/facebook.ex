Code.ensure_loaded?(Hex) and Hex.start

defmodule Facebook.Mixfile do
  use Mix.Project

  def project do
    [
      app: :facebook,
      version: "0.17.0",
      elixir: "~> 1.0",
      description: description(),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      source_url: "https://github.com/mweibel/facebook.ex"
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Facebook, [] },
      applications: [:httpoison, :json, :logger],
      env: [
        env: :dev,
        graph_url: "https://graph.facebook.com",
        graph_video_url: "https://graph-video.facebook.com",
        appsecret: nil
      ]
    ]
  end

  defp description do
    """
    Facebook Graph API Wrapper written in Elixir.
    Please note, this is very much a work in progress. Feel free to contribute using pull requests.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/mweibel/facebook.ex"
      },
      maintainers: [
        "mweibel",
        "jovannypcg"
      ]
    ]
  end

  defp deps do
    [
      {:json, ">= 0.3.3"},
      {:httpoison, "~> 0.13"},

      {:mock, "~> 0.2.0", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},

      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.13.0", only: :dev}
    ]
  end

  defp aliases do
    [
      "quality": [
        "test",
        "credo --strict"
      ]
    ]
  end
end
