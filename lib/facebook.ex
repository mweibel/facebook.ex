defmodule Facebook do
	@moduledoc """
	Provides API wrappers for the Facebook Graph API

	See: https://developers.facebook.com/docs/graph-api
	"""

	@doc "Start hook"
	def start(_type, _args) do
		{:ok, self}
	end

	@type fields :: list
	@type access_token :: String.t
	@type response :: {:json, HashDict.t} | {:body, String.t}
	@type options :: list

	@doc """
	Basic user infos of the logged in user (specified by the access_token)

	See: https://developers.facebook.com/docs/graph-api/reference/user/
	"""
	@spec me(fields, access_token) :: response
	def me(fields, access_token) do
		me(fields, access_token, [])
	end

	@doc """
	Basic user infos of the logged in user (specified by the access_token).
	"""
	@spec me(fields, access_token, options) :: response
	def me(fields, access_token, options) do
		Facebook.Graph.get("/me", [
			{<<"fields">>, fields},
			{<<"access_token">>, access_token}
		], options)
	end

	@doc """
	Likes of the currently logged in user (specified by the access_token)

	See: https://developers.facebook.com/docs/graph-api/reference/user/likes
	"""
	@spec myLikes(access_token) :: response
	def myLikes(access_token) do
		myLikes(access_token, [])
	end

	@doc """
	Likes of the currently logged in user (specified by the access_token)

	See: https://developers.facebook.com/docs/graph-api/reference/user/likes
	"""
	@spec myLikes(access_token, options) :: response
	def myLikes(access_token, options) do
		Facebook.Graph.get("/me/likes", [
			{<<"access_token">>, access_token}
		], options)
	end
end
