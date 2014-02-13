defmodule Facebook.Graph do
	@define("GRAPH_URL", "https://graph.facebook.com")

	def start_link do
	end

	@doc """
	Accepts a relative URL and returns JSON data
	"""
	def get(url, headers, payload, options) do
		request(:get, headers, payload, options)
	end

	defp request(method, url, headers, payload, options) do
		{:ok, status_code, headers, client_ref} = :hackney.request(method,
							url, headers, payload, options)
		{:ok, body} = :hackney.body(client_ref)
		JSON.decode(body)
	end
end