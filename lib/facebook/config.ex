defmodule Facebook.Config do
  @moduledoc """
  Config helpers
  """

  # URL to the Facebook Graph including the version (no slash at the end!)
  def graph_url do
    Application.fetch_env! :facebook, :graph_url
  end

  # URL to the Facebook Graph for video including the version (no slash at the end!)
  def graph_video_url do
    Application.fetch_env! :facebook, :graph_video_url
  end

  # App secret a.k.a. client secret
  def appsecret do
    IO.warn("'appsecret' method is deprecated. Please use 'app_secret'", Macro.Env.stacktrace(__ENV__))
    app_secret()
  end
  def app_secret do
    with :error <- Application.fetch_env(:facebook, :appsecret)
    do
      Application.fetch_env! :facebook, :app_secret
    else
      {:ok, secret} ->
        IO.warn("'appsecret' configuration value is deprecated. Please use 'app_secret'", Macro.Env.stacktrace(__ENV__))
        secret
    end
  end

  def appsecret(appsecret) do
    IO.warn("'appsecret' method value is deprecated. Please use 'app_secret'", Macro.Env.stacktrace(__ENV__))
    app_secret(appsecret)
  end
  def app_secret(app_secret) do
    case Application.fetch_env(:facebook, :appsecret) do
      {:ok, _} ->
        IO.warn("'appsecret' configuration value is deprecated. Please use 'app_secret'", Macro.Env.stacktrace(__ENV__))
        Application.put_env :facebook, :appsecret, app_secret
      _ ->
        Application.put_env :facebook, :app_secret, app_secret
    end
  end

  # App id, a.k.a. client id
  def app_id do
    Application.fetch_env! :facebook, :app_id
  end

  # App access token
  def app_access_token do
    Application.fetch_env! :facebook, :app_access_token
  end
end
