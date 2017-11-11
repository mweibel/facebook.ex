defmodule Facebook.GraphAPI do
  @moduledoc false

  use HTTPoison.Base

  alias Facebook.Config

  def process_url(url), do: Config.graph_url <> url

  def process_response_body(body) do
    body
      |> JSON.decode
  end
end
