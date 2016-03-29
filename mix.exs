Code.ensure_loaded?(Hex) and Hex.start

defmodule Facebook.Mixfile do
  use Mix.Project

  def project do
    [
      app: :facebook,
      version: "0.4.2",
      elixir: "~> 1.0",
      description: description,
      package: package,
      deps: deps,
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
        graph_url: "https://graph.facebook.com/v2.0",
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
        "hectorip"
      ]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:json, ">= 0.3.3"},
      {:hackney, "~> 1.0"},
      {:libex_config, ">= 0.1.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.6", only: :dev}
    ]
  end
end
