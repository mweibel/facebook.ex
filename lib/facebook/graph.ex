defmodule Facebook.Graph do
	require Lager

	@moduledoc """
	HTTP Wrapper for the Graph API using hackney.
	"""

	@graph_url <<"https://graph.facebook.com">>

	@doc """
	Start the API
	"""
	@spec start_link :: :ok
	def start_link do
		:ok
	end

	@type path :: String.t
	@type response :: {:json, HashDict.t} | {:body, String.t}
	@type options :: list
	@type params :: list
	@type method :: :get | :post | :put | :head
	@type url :: String.t
	@type payload :: binary

	@doc """
	HTTP GET using a path
	"""
	@spec get(path) :: response
	def get(path) do
		get(path, [], [])
	end

	@doc """
	HTTP GET using path and options
	"""
	@spec get(path, options) :: response
	def get(path, options) do
		get(path, [], options)
	end

	@doc """
	HTTP GET using path, params and options
	"""
	@spec get(path, params, options) :: response
	def get(path, params, options) do
		url = :hackney_url.make_url(@graph_url, path, params)
		request(:get, url, options)
	end

	@spec request(method, url, options) :: response
	defp request(method, url, options) do
		request(method, url, <<>>, options)
	end

	@spec request(method, url, payload, options) :: response
	defp request(method, url, payload, options) do
		headers = []
		case :hackney.request(method, url, headers, payload, options) do
			{:ok, _status_code, _headers, client_ref} ->
				{:ok, body} = :hackney.body(client_ref)
				Lager.info("body: ~p", [body])
				case JSON.decode(body) do
					{:ok, data} ->
						{:json, data}
					_ ->
						{:body, body}
				end
			error ->
				Lager.error("error: ~p", [error])
				error
		end
	end
end