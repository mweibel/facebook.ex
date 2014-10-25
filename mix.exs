Code.ensure_loaded?(Hex) and Hex.start

defmodule Facebook.Mixfile do
	use Mix.Project

	def project do
		[
			app: :facebook,
			version: "0.2.1",
			elixir: "~> 1.0.0",
			description: description,
			package: package,
			deps: deps
		]
	end

	# Configuration for the OTP application
	def application do
		[
			mod: { Facebook, [] },
			applications: [:json, :hackney],
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
			contributors: [
				"Michael Weibel",
				"Garrett Amini"
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
			{:json, ">= 0.3.0"},
			{:hackney, "~> 0.14.1"},
			{:libex_config, ">= 0.1.0"}
		]
	end
end
