defmodule Facebook.GraphVideoAPI do
  @moduledoc false

  use HTTPoison.Base

  alias Facebook.Config

  def process_url(url), do: Config.graph_video_url() <> url

  def process_response_body(body), do: JSON.decode(body)
end
