defmodule Facebook do
	def start(_type, _args) do
		{:ok, self}
	end

	def me(fields, access_token) do
		me(fields, access_token, nil)
	end

	def me(fields, access_token, options) do
		Facebook.Graph.get("/me", [
			{"fields": fields, "access_token": access_token}
		], options)
	end
end
