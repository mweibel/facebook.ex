defmodule Facebook.Config do
  @moduledoc """
  Reads configuration on application start, parses all environment variables (if any)
  and caches the final config in memory to avoid parsing on each read afterwards.
  """

  use GenServer

  @config_keys ~w(
    graph_url
    graph_video_url
    app_id
    appsecret
    app_secret
    app_access_token
    request_conn_timeout
    request_recv_timeout
  )a

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    config =
      @config_keys
      |> Enum.map(fn key -> {key, get_config_value(key)} end)
      |> Map.new()

    {:ok, config}
  end

  # URL to the Facebook Graph including the version
  def graph_url, do: get(:graph_url)

  def graph_video_url, do: get(:graph_video_url)

  # App id, a.k.a. client id
  def app_id, do: get(:app_id)

  # App secret a.k.a. client secret
  @deprecated "Use app_secret/0 instead"
  def appsecret, do: app_secret()

  def app_secret do
    with nil <- get(:appsecret) do
      get(:app_secret)
    else
      secret ->
        IO.warn(
          "'appsecret' configuration value is deprecated. Please use 'app_secret'",
          Macro.Env.stacktrace(__ENV__)
        )

        secret
    end
  end

  @deprecated "Use app_secret/1 instead"
  def appsecret(appsecret), do: app_secret(appsecret)

  def app_secret(app_secret) do
    case get(:appsecret) do
      nil ->
        put(:app_secret, app_secret)

      _ ->
        IO.warn(
          "'appsecret' configuration value is deprecated. Please use 'app_secret'",
          Macro.Env.stacktrace(__ENV__)
        )

        put(:appsecret, app_secret)
    end
  end

  # App access token
  def app_access_token, do: get(:app_access_token)

  # Request conn_timeout
  def request_conn_timeout, do: get(:request_conn_timeout)

  # Request recv_timeout
  def request_recv_timeout, do: get(:request_recv_timeout)

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  def put(key, value), do: GenServer.call(__MODULE__, {:put, key, value})

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    {:reply, value, Map.put(state, key, value)}
  end

  defp get_config_value(key) do
    :facebook
    |> Application.get_env(key)
    |> parse_config_value()
  end

  defp parse_config_value({:system, env_name}), do: fetch_env!(env_name)

  defp parse_config_value({:system, :integer, env_name}) do
    env_name
    |> fetch_env!()
    |> String.to_integer()
  end

  defp parse_config_value(value), do: value

  # System.fetch_env!/1 support for older versions of Elixir
  defp fetch_env!(env_name) do
    case System.get_env(env_name) do
      nil ->
        raise ArgumentError,
          message: "could not fetch environment variable \"#{env_name}\" because it is not set"

      value ->
        value
    end
  end
end
