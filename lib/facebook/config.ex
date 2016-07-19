defmodule Facebook.Config do

  # URL to the Facebook Graph including the version.
  def graph_url do
    Application.fetch_env! :facebook, :graph_url
  end

  # App secret
  def appsecret do
    Application.fetch_env! :facebook, :appsecret
  end

  def appsecret(appsecret) do
    Application.put_env :facebook, :appsecret, appsecret
  end
end
