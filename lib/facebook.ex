defmodule Facebook do
	@moduledoc """
	Provides API wrappers for the Facebook Graph API

	See: https://developers.facebook.com/docs/graph-api
	"""

	alias Facebook.Config

	@doc "Start hook"
	def start(_type, _args) do
		{:ok, self}
	end	

	@type fields :: list
	@type access_token :: String.t
	@type response :: {:json, HashDict.t} | {:body, String.t}
	@type options :: list
	@type using_appsecret :: boolean	

	@doc """
	If you want to use an appsecret proof, pass it into set_appsecret:
	Facebook.set_appsecret("appsecret")	

	See: https://developers.facebook.com/docs/graph-api/securing-requests
	"""
	def set_appsecret(appsecret) do
		Config.appsecret(appsecret)
	end

	@doc """
	Basic user infos of the logged in user (specified by the access_token)

	See: https://developers.facebook.com/docs/graph-api/reference/user/
	"""
	@spec me(fields, access_token) :: response
	def me(fields, access_token) when is_binary(fields) do
		me([fields: fields], access_token, [])
	end

	def me(fields, access_token) do
		me(fields, access_token, [])
	end

	@doc """
	Basic user infos of the logged in user (specified by the access_token).
	"""
	@spec me(fields, access_token, options) :: response
	def me(fields, access_token, options) when is_binary(fields) do
		me([fields: fields], access_token, options)
	end

	def me(fields, access_token, options) do
		if !nil?Config.appsecret do
			fields = fields ++ [appsecret_token: encrypt(access_token)]
		end

		Facebook.Graph.get("/me", fields ++ [access_token: access_token], options)
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

	@doc """
	Retrieves a list of granted permissions

	See: https://developers.facebook.com/docs/graph-api/reference/user/permissions
	"""
	@spec permissions(user_id :: integer | String.t, access_token) :: response
	def permissions(user_id, access_token) do
		Facebook.Graph.get(~s(/#{user_id}/permissions), [
			{<<"access_token">>, access_token}
		])
	end

	defp encrypt(token) do
		:crypto.hmac(:sha256, Config.appsecret, token)
	end
end