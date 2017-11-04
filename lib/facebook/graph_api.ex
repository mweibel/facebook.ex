defmodule Facebook.GraphApi do
  use HTTPoison.Base

  alias Facebook.Config

  def process_url(url), do: Config.graph_url <> url

  def process_response_body(body) do
    body
    |> JSON.decode
  end

  def format_response({:ok, %{body: {:ok, %{"error" => error}}}}) do
    {:error, error}
  end

  def format_response({:ok, %{body: body}}), do: body

  def format_response({:error, error}), do: {:error, error}
end
