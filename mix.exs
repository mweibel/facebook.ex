Code.ensure_loaded?(Hex) and Hex.start

defmodule Facebook.Mixfile do
  use Mix.Project

  def project do
    [
      app: :facebook,
      version: "0.15.0",
      elixir: "~> 1.0",
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/mweibel/facebook.ex"
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Facebook, [] },
      applications: [:json, :hackney, :logger],
      env: [
        env: :dev,
        graph_url: "https://graph.facebook.com/v2.9",
        graph_video_url: "https://graph-video.facebook.com/v2.9",
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
      {:hackney, "~> 1.6"},
      {:ex_doc, ">= 0.13.0", only: :dev},
      {:apex, "~>1.1.0"},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false}
    ]
  end
end
