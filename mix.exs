 Code.ensure_loaded?(Hex) and Hex.start

defmodule Facebook.Mixfile do
	use Mix.Project

	def project do
		[ app: :facebook,
			version: "0.0.4",
			elixir: "~> 0.13.0",
			description: description,
			package: package,
			deps: deps ]
	end

	# Configuration for the OTP application
	def application do
		[
			mod: { Facebook, [] },
			applications: [:json, :exlager, :hackney]
		]
	end

	defp description do
		"""
		Facebook Graph API Wrapper written in Elixir.
		Please note, this is very much a work in progress. Feel free to contribute using pull requests.
		"""
	end

	defp package do
		licenses: ["MIT"],
		links: [
			{"GitHub", "https://github.com/mweibel/facebook.ex"}
		]
	end

	# Returns the list of dependencies in the format:
	# { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
	#
	# To specify particular versions, regardless of the tag, do:
	# { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
	defp deps do
		[
			{:json, "~>0.2.8", [github: "cblage/elixir-json", tag: "v0.2.8"]},
			{:hackney, "~>0.12.1", [github: "benoitc/hackney", tag: "0.12.1"]},
			{:exlager, "~>0.2.1", github: "khia/exlager"},
		]
	end
end
