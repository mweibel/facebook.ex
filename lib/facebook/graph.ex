defmodule Facebook.Graph do
	@graph_url "https://graph.facebook.com"

	def start_link do
		:ok
	end

	def get(path) do
		get(path, nil, nil)
	end

	@doc """

	"""
	def get(path, options) do
		get(path, nil, options)
	end

	@doc """
	Accepts a relative URL and returns JSON data
	"""
	def get(path, params, options) do
		url = :hackney_url.make_url(@graph_url, path, params)
		request(:get, url, options)
	end

	defp request(method, url, options) do
		request(method, url, nil, options)
	end

	defp request(method, url, payload, options) do
		headers = []
		case :hackney.request(method, url, headers, payload, options) do
			{:ok, status_code, headers, client_ref} ->
				{:ok, body} = :hackney.body(client_ref)
				case JSON.decode(body) do
					{:ok, data} ->
						{:json, data}
					_ ->
						{:body, body}
				end
			error ->
				error
		end
	end
end