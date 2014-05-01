defmodule Facebook.Config do
  use LibEx.Config, application: :facebook

  @doc """
    iex> Facebook.Config.appsecret
    "appsecrettokenhere"
  """
  defkey :appsecret

end