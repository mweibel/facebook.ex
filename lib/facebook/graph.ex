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
    Logger.debug fn ->
      "[#{method}] #{url} #{inspect headers} #{inspect payload}"
    end
    case :hackney.request(method, url, headers, payload, options) do
      {:ok, _status_code, _headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        Logger.debug fn ->
          "body: #{inspect body}"
        end
        case JSON.decode(body) do
          {:ok, data} ->
            {:json, data}
          _ ->
            {:body, body}
        end
      error ->
        Logger.error fn ->
          "error: #{inspect error}"
        end
        error
    end
  end
end
