defmodule Facebook do
  use Application
  use Supervisor

  @moduledoc """
  Provides API wrappers for the Facebook Graph API

  See: https://developers.facebook.com/docs/graph-api
  """

  alias Facebook.Config

  @doc "Start hook"
  def start(_type, _args) do
    start_link([])
  end

  @doc "Supervisor start"
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Facebook.Graph, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  @type fields :: list
  @type access_token :: String.t
  @type response :: {:json, HashDict.t} | {:body, String.t}
  @type using_appsecret :: boolean
  @type reaction :: :reaction

  @doc """
  If you want to use an appsecret proof, pass it into set_appsecret:

  ## Example
      iex> Facebook.setAppsecret("appsecret")

  See: https://developers.facebook.com/docs/graph-api/securing-requests
  """
  def setAppsecret(appsecret) do
    Config.appsecret(appsecret)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  ## Example
      iex> Facebook.me("id,first_name", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields :: String.t, access_token) :: response
  def me(fields, access_token) when is_binary(fields) do
    me([fields: fields], access_token)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  ## Example
      iex> Facebook.me([fields: "id,first_name"], "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields, access_token) :: response
  def me(fields, access_token) do
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get("/me", fields ++ [access_token: access_token])
  end

  @doc """
  A Picture for a Facebook User

  ## Example
      iex> Facebook.picture("<Some Id>", "small", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/picture/
  """
  @spec picture(user_id :: String.t, type :: String.t, access_token) :: response
  def picture(user_id, type, access_token) do
    fields = [type: type, redirect: false, access_token: access_token]

    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get("/#{user_id}/picture", fields)
  end

  @doc """
  Likes of the currently logged in user (specified by the access_token)

  ## Example
      iex> Facebook.myLikes("<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/likes
  """
  @spec myLikes(access_token) :: response
  def myLikes(access_token) do
    fields = [access_token: access_token]
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get("/me/likes", fields)
  end

  @doc """
  Retrieves a list of granted permissions

  ## Example
      iex> Facebook.permissions("<Some Id>", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/permissions
  """
  @spec permissions(user_id :: integer | String.t, access_token) :: response
  def permissions(user_id, access_token) do
    fields = [access_token: access_token]
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get(~s(/#{user_id}/permissions), fields)
  end

  @doc """
  Get the count of fans for the provided page_id

  ## Example
      iex> Facebook.fanCount("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page/
  """
  @spec fanCount(page_id :: integer | String.t, access_token) :: integer
  def fanCount(page_id, access_token) do
    {:json, %{"fan_count" => fanCount}} = page(page_id, access_token, ["fan_count"])
    fanCount
  end

  @doc """
  *Deprecated:* Please use fanCount instead.

  Get the count of fans for the provided page_id

  ## Example
      iex> Facebook.pageLikes("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page/
  """
  @spec pageLikes(page_id :: integer | String.t, access_token) :: integer
  def pageLikes(page_id, access_token) do
    fanCount(page_id, access_token)
  end

  @doc """
  Basic page information for the provided page_id

  ## Example
      iex> Facebook.page("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token) :: response
  def page(page_id, access_token) do
    page(page_id, access_token, [])
  end

  @doc """
  Get page information for the specified fields for the provided page_id

  ## Example
      iex> Facebook.page("CocaColaMx", "<Your Token>", "id")

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token, fields) :: response
  def page(page_id, access_token, fields) do
    params = [fields: fields, access_token: access_token]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get(~s(/#{page_id}), params)
  end

  @doc """
  Gets the feed of posts (including status updates) and links published by this
  page, or by others on this page.

  This function can retrieve the four types:
    * feed
    * posts
    * promotable posts (*Admin permission needed*)
    * tagged posts

  A scope must be provided. It is a string, which represents the type of feed.

  *A limit of posts may be given. The maximum number that must be provided is
  100.*

  ## Examples
      iex> Facebook.pageFeed(:posts, "CocaColaMx", "<Your Token>")
      iex> Facebook.pageFeed(:tagged, "CocaColaMx", "<Your Token>", 55)
      iex> Facebook.pageFeed(:promotable_posts, "CocaColaMx", "<Your Token>")
      iex> Facebook.pageFeed(:feed, "CocaColaMx", "<Your Token>", 55, "id,name")

  See: https://developers.facebook.com/docs/graph-api/reference/page/feed
  """
  @spec pageFeed(scope :: atom | String.t, page_id :: String.t, access_token, limit :: number, fields :: String.t) :: Map.t
  def pageFeed(scope, page_id, access_token, limit \\ 25, fields \\ "") when limit <= 100 do
    params = [access_token: access_token, limit: limit, fields: fields]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end

    {_, content} = Facebook.Graph.get(~s(/#{page_id}/#{scope}), params)

    content
  end

  @doc """
  Gets the number of elements that a scope has in a given object.

  An *object* stands for: post, comment, link, status update, photo.

  If you want to get the likes of a page, please see *fanCount*.

  Expected scopes:
    * :likes
    * :comments

  ## Example
      iex> Facebook.objectCount(:likes, "1326382730725053_1326476257382367", "<Token>")
      2
      iex> Facebook.objectCount(:comments, "1326382730725053_1326476257382367", "<Token>")
      2

  See: https://developers.facebook.com/docs/graph-api/reference/object/likes
  See: https://developers.facebook.com/docs/graph-api/reference/object/comments
  """
  @spec objectCount(scope :: atom, object_id :: String.t, access_token) :: number
  def objectCount(scope, object_id, access_token) when is_atom(scope) do
    params = [access_token: access_token, summary: true]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end

    scp = scope
      |> Atom.to_string
      |> String.downcase

    Facebook.Graph.get(~s(/#{object_id}/#{scp}), params)
      |> getSummary
      |> summaryCount
  end

  @doc """
  Gets the number of reactions that an object has.

  Expected type of reactions:
    * :haha
    * :wow
    * :thankful
    * :sad
    * :angry
    * :love
    * :none

  ## Examples
      iex> Facebook.objectCount(:reaction, :wow, "769860109692136_1173416799336463", "<Token>")
      2
      iex> Facebook.objectCount(:reaction, :haha, "769860109692136_1173416799336463", "<Token>")
      12
      iex> Facebook.objectCount(:reaction, :thankful, "769860109692136_1173416799336463", "<Token>")
      33
  """
  @spec objectCount(reaction, react_type :: atom, object_id :: String.t, access_token) :: number
  def objectCount(:reaction, react_type, object_id, access_token) when is_atom(react_type) do
    type = react_type
      |> Atom.to_string
      |> String.upcase

    params = [access_token: access_token, type: type, summary: "total_count"]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get(~s(/#{object_id}/reactions), params)
      |> getSummary
      |> summaryCount
  end

  @doc """
  Exchange an authorization code for an access token

  ## Examples
      iex> Facebook.accessToken("client_id", "client_secret", "redirect_uri", "code")
      %{
        "access_token" => "ACCESS_TOKEN",
        "expires_in" => 5183976,
        "token_type" => "bearer"
      }

  See: https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow#confirm
  """
  @spec accessToken(String.t, String.t, String.t, String.t) :: String.t
  def accessToken(client_id, client_secret, redirect_uri, code) do
    params = [
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code]

    Facebook.Graph.get(~s(/oauth/access_token), params)
      |> getAccessToken
  end

  """
  Provides the summary of a GET request when the 'summary' query parameter is
  set to true.
  """
  defp getSummary(summary_response) do
    case summary_response do
      {:json, %{"error" => error}} -> %{"error" => error}
      {:json, info_map} -> info_map
    end
  end

  """
  Extract the access token from the access token response
  """
  defp getAccessToken(access_token_response) do
    case access_token_response do
      {:json, %{"error" => error}} -> %{"error" => error}
      {:json, info_map} -> info_map
    end
  end

  """
  Gets the 'total_count' attribute from a summary request.
  """
  defp summaryCount(%{"total_count" => count}), do: count

  """
  Returns an error if the summary request fails.
  """
  defp summaryCount(%{"error" => error}), do: %{"error" => error}

  """
  'Encrypts' the token together with the app secret according to the guidelines of facebook.
  """
  defp encrypt(token) do
    :crypto.hmac(:sha256, Config.appsecret, token)
    |> Base.encode16(case: :lower)
  end
end
