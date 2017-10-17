defmodule Facebook.Graph do
  require Logger

  alias Facebook.Config

  @moduledoc """
  HTTP Wrapper for the Graph API using hackney.
  """

  @doc """
  Start the API
  """
  @spec start_link :: :ok
  def start_link do
    :ignore
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
  HTTP GET using path and params
  """
  @spec get(path, params) :: response
  def get(path, params) do
    get(path, params, [])
  end

  @doc """
  HTTP GET using path, params and options
  """
  @spec get(path, params, options) :: response
  def get(path, params, options) do
    url = :hackney_url.make_url(Config.graph_url, path, params)
    request(:get, url, options)
  end

  @doc """
  HTTP POST using path, params and options
  """
  @spec post(path, params, options) :: response
  def post(path, params, options) do
    url = :hackney_url.make_url(Config.graph_url, path, params)
    request(:post, url, options)
  end

  @doc """
  HTTP POST using path, body, params and options
  """
  @spec post(path, payload, params, options) :: response
  def post(path, payload, params, options) do
    url = :hackney_url.make_url(Config.graph_url, path, params)
    request(:post, url, payload, options)
  end

  @doc """
  HTTP POST for video api using path, body, params and options
  """
  @spec post(:video, path, payload, params, options) :: response
  def post(:video, path, payload, params, options) do
    url = :hackney_url.make_url(Config.graph_video_url, path, params)
    request(:post, url, payload, options)
  end

  @doc """
  HTTP generic request (GET, POST, etc) using a full URL and options
  """
  @spec request(method, url, options) :: response
  def request(method, url, options) do
    request(method, url, <<>>, options)
  end

  @doc """
  HTTP generic request (GET, POST, etc) using a full URL, payload and options
  """
  @spec request(method, url, payload, options) :: response
  def request(method, url, payload, options) do
    headers = []
    :hackney.request(method, url, headers, payload, options)
      |> get_response_body()
      |> parse_response_body()
      |> format_response_body()
  end

  defp get_response_body({:ok, _status_code, _headers, client_ref}) do
    :hackney.body(client_ref)
  end
  defp get_response_body({:error, reason}), do: {:error, reason}

  defp parse_response_body({:ok, body}) do
    JSON.decode(body)
  end
  defp parse_response_body({:error, reason}), do: {:error, reason}

  defp format_response_body({:ok, %{"error" => error}}) do
    {:error, error}
  end
  # defp format_response_body({:ok, %{"data" => data} = rest}) do
  #   Apex.ap rest
  #   {:ok, data}
  # end
  # defp format_response_body({:ok, %{"summary" => summary}}) do
  #   {:ok, summary}
  # end
  defp format_response_body({:ok, resp}) do
    {:ok, resp}
  end
  defp format_response_body({:error, reason}), do: {:error, reason}
end
