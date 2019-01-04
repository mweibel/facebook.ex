defmodule Facebook.GraphAPI do
  @moduledoc false

  use HTTPoison.Base

  alias Facebook.Config

  def process_request_options(options) do
    updated_options =
      case Config.request_conn_timeout() do
        :error -> options
        val -> options ++ [timeout: val]
      end

    case Config.request_recv_timeout() do
      :error -> updated_options
      val -> updated_options ++ [recv_timeout: val]
    end
  end

  def process_url("https://graph.facebook.com/" <> _ = url), do: url

  def process_url(url), do: Config.graph_url() <> url

  def process_response_body(body) do
    body
    |> JSON.decode()
  end
end
