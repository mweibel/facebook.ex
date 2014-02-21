defmodule Facebook do
	def start(_type, _args) do
		{:ok, self}
	end

	def me(fields, access_token) do
		me(fields, access_token, [])
	end

	def me(fields, access_token, options) do
		Facebook.Graph.get("/me", [
			{<<"fields">>, fields},
			{<<"access_token">>, access_token}
		], options)
	end

	def myLikes(access_token) do
		myLikes(access_token, [])
	end

	def myLikes(access_token, options) do
		Facebook.Graph.get("/me/likes", [
			{<<"access_token">>, access_token}
		], options)
	end
end
