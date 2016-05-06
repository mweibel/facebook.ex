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
  @type options :: list
  @type using_appsecret :: boolean

  @doc """
  If you want to use an appsecret proof, pass it into set_appsecret:
  Facebook.set_appsecret("appsecret")

  See: https://developers.facebook.com/docs/graph-api/securing-requests
  """
  def set_appsecret(appsecret) do
    Config.appsecret(appsecret)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token)

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields, access_token) :: response
  def me(fields, access_token) when is_binary(fields) do
    me([fields: fields], access_token, [])
  end

  def me(fields, access_token) do
    me(fields, access_token, [])
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields :: String.t, access_token, options) :: response
  def me(fields, access_token, options) when is_binary(fields) do
    me([fields: fields], access_token, options)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields, access_token, options) :: response
  def me(fields, access_token, options) do
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get("/me", fields ++ [access_token: access_token], options)
  end

  @doc """
  A Picture for a Facebook User

  See: https://developers.facebook.com/docs/graph-api/reference/user/picture/
  """
  @spec picture(user_id :: String.t, type :: String.t, access_token, options) :: response
  def picture(user_id, type, access_token, options \\ []) do
    fields = [type: type, redirect: false, access_token: access_token]

    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get("/#{user_id}/picture", fields, options)
  end

  @doc """
  Likes of the currently logged in user (specified by the access_token)

  See: https://developers.facebook.com/docs/graph-api/reference/user/likes
  """
  @spec myLikes(access_token) :: response
  def myLikes(access_token) do
    myLikes(access_token, [])
  end

  @doc """
  Likes of the currently logged in user (specified by the access_token)

  See: https://developers.facebook.com/docs/graph-api/reference/user/likes
  """
  @spec myLikes(access_token, options) :: response
  def myLikes(access_token, options) do
    fields = [access_token: access_token]
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get("/me/likes", fields, options)
  end

  @doc """
  Retrieves a list of granted permissions

  See: https://developers.facebook.com/docs/graph-api/reference/user/permissions
  """
  @spec permissions(user_id :: integer | String.t, access_token) :: response
  def permissions(user_id, access_token) do
    permissions(user_id, access_token, [])
  end

  @doc """
  Retrieves a list of granted permissions

  See: https://developers.facebook.com/docs/graph-api/reference/user/permissions
  """
  @spec permissions(user_id :: integer | String.t, access_token, options) :: response
  def permissions(user_id, access_token, options) do
    fields = [access_token: access_token]
    if !is_nil(Config.appsecret) do
      fields = fields ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get(~s(/#{user_id}/permissions), fields, options)
  end

  @doc """
  Get the number of likes for the provided page_id
  """
  @spec pageLikes(page_id :: integer | String.t, access_token) :: integer
  def pageLikes(page_id, access_token) do
    {:json, %{"likes" => likes}} = page(page_id, access_token, ["likes"], [])
    likes
  end

  @doc """
  Basic page information for the provided page_id

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token) :: response
  def page(page_id, access_token) do
    page(page_id, access_token, [], [])
  end

  @doc """
  Get page information for the specified fields for the provided page_id

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token, fields, options) :: response
  def page(page_id, access_token, fields, options) do
    params = [fields: fields, access_token: access_token]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end
    Facebook.Graph.get(~s(/#{page_id}), params, options)
  end

  @doc """
  Feed of posts for the provided page_id.
  The maximum posts returned is 25, which is the facebook's default.

  ## Example
      iex> Facebook.pageFeed("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page/feed
  """
  def pageFeed(page_id, access_token) do
    pageFeed(page_id, access_token, 25)
  end

  @doc """
  Get the feed of posts (including status updates) and links published by others
  or the page specified in page_id.

  A limit of posts may be given. The maximim number that must be provided, is
  100.

  ## Example
      iex> Facebook.pageFeed("CocaColaMx", "<Your Token>", 55)

  See: https://developers.facebook.com/docs/graph-api/reference/page/feed
  """
  def pageFeed(page_id, access_token, limit) when limit <= 100 do
    params = [access_token: access_token, limit: limit]
    if !is_nil(Config.appsecret) do
      params = params ++ [appsecret_proof: encrypt(access_token)]
    end

    Facebook.Graph.get(~s(/#{page_id}/feed), params)
  end

  @doc """
  Gets the total number of people who liked an object.
  An *object* stands for: post, comment, link, status update, photo.

  If you want to get the likes of a page, please see *pageLikes*.

  ## Example
      iex> Facebook.objectCount(:likes, "1326382730725053_1326476257382367", "<Token>")
      2

  See: https://developers.facebook.com/docs/graph-api/reference/object/likes
  """
  def objectCount(:likes, object_id, access_token) do
    :likes
      |> Atom.to_string
      |> objectSummary(object_id, access_token)
      |> summaryCount
  end

  @doc """
  Gets the total number of people who commented an object.
  An *object* stands for: post, comment, link, status update, photo.

  ## Example
      iex> Facebook.objectCount(:comments, "1326382730725053_1326476257382367", "<Token>")
      2

  See: https://developers.facebook.com/docs/graph-api/reference/object/comments
  """
  def objectCount(:comments, object_id, access_token) do
    :comments
      |> Atom.to_string
      |> objectSummary(object_id, access_token)
      |> summaryCount
  end

  """
  Provides the summary of a GET request when the 'summary' query parameter is
  set to true.

  ## Example
      iex> _objectSummary("comments", "1326382730725053_1326476257382367", "<Token>")
      %{"total_count" => 47}
  """
  defp objectSummary(scope, object_id, access_token) do
      summary = fn
        {:json, %{"error" => error}} -> %{:error => error}
        {:json, info_map} ->
          info_map
            |> Map.fetch!("summary")
      end

      params = [access_token: access_token, summary: true]
      if !is_nil(Config.appsecret) do
        params = params ++ [appsecret_proof: encrypt(access_token)]
      end

      Facebook.Graph.get(~s(/#{object_id}/#{scope}), params)
        |> summary.()
  end

  """
  Gets the 'total_count' attribute from a summary request.
  """
  defp summaryCount(%{"total_count" => count}), do: count

  """
  Returns a error if the summary requests failed.
  """
  defp summaryCount(%{"error" => error}), do: error

  defp encrypt(token) do
    :crypto.hmac(:sha256, Config.appsecret, token)
    |> Base.encode16(case: :lower)
  end
end
