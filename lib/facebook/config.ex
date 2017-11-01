defmodule Facebook.Config do
  @moduledoc """
  Config helpers
  """

  # URL to the Facebook Graph including the version.
  def graph_url do
    Application.fetch_env! :facebook, :graph_url
  end

  def graph_video_url do
    Application.fetch_env! :facebook, :graph_video_url
  end

  # App secret
  def appsecret do
    Application.fetch_env! :facebook, :appsecret
  end

  def appsecret(appsecret) do
    Application.put_env :facebook, :appsecret, appsecret
  end
end
