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
  @type response :: {:ok, HashDict.t} | {:body, String.t}
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
    fields = fields
      |> add_app_secret(access_token)

    Facebook.Graph.get("/me", fields ++ [access_token: access_token])
  end

  @doc """
  Publish to a feed. Author (user or page) is determined from the supplied token.

  The `feed_id` is the id for the user or page feed to publish to.
  Apps need both `manage_pages` and `publish_pages` to be able to publish as a Page.
  The `publish_actions` permission is required to publish as an individual.

  See Facebook's publishing documentation for more info:

  * https://developers.facebook.com/docs/pages/publishing
  * https://developers.facebook.com/docs/pages/publishing#personal_post
  * https://developers.facebook.com/docs/facebook-login/permissions#reference-publish_pages

  ## Examples
      iex> # publish a message
      iex> Facebook.publish(:feed, "<Feed Id>", [message: "<Message Body"], "<Access Token>")

      iex> # publish a link and message
      iex> Facebook.publish(:feed, "<Feed Id>", [message: "<Message Body", link: "www.example.com"], "<Access Token>")

  """
  @spec publish(:feed, feed_id :: String.t, fields, access_token) :: response
  def publish(:feed, feed_id, fields, access_token) do
    params = fields ++ [access_token: access_token]
    Facebook.Graph.post("/#{feed_id}/feed", params, [])
  end

  @doc """
  Publish media to a feed. Author (user or page) is determined from the supplied token.

  The `feed_id` is the id for the user or page feed to publish to.
  Same :feed publishing permissions apply.


  ## Example
      iex> Facebook.publish(:photo, "<Feed Id>", "<Image Path>", [], "<Access Token>")
      {:ok, %{"id" => "..."}}

      iex> Facebook.publish(:video, "<Feed Id>", "<Video Path>", [], "<Access Token>")
      {:ok, %{"id" => "..."}}

  """
  @spec publish(:photo, page_id :: String.t, file_path :: String.t, fields, access_token) :: response
  def publish(:photo, page_id, file_path, fields, access_token) do
    params = fields ++ [access_token: access_token]
    payload = media_payload(file_path)
    Facebook.Graph.post("/#{page_id}/photos", payload, params, [])
  end

  @spec publish(:video, page_id :: String.t, file_path :: String.t, fields, access_token) :: response
  def publish(:video, page_id, file_path, fields, access_token) do
    params = fields ++ [access_token: access_token]
    payload = media_payload(file_path)
    Facebook.Graph.post(:video, "/#{page_id}/videos", payload, params, [])
  end

  defp media_payload(file_path) do
    {:multipart, [{:file, file_path, {"form-data", [filename: Path.basename(file_path)]}, []}]}
  end

  @doc """
  A Picture for a Facebook User

  ## Example
      iex> Facebook.picture("<Some Id>", "small", "<Your Token>")
      {:ok, %{"data": "..."}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/picture/
  """
  @spec picture(user_id :: String.t, type :: String.t, access_token) :: response
  def picture(user_id, type, access_token) do
    fields = [type: type, redirect: false, access_token: access_token]
      |> add_app_secret(access_token)

    Facebook.Graph.get("/#{user_id}/picture", fields)
  end

  @doc """
  Likes of the currently logged in user (specified by the access_token)

  ## Example
      iex> Facebook.my_likes("<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/user/likes
  """
  @spec my_likes(access_token) :: response
  def my_likes(access_token) do
    fields = [access_token: access_token]
      |> add_app_secret(access_token)

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
      |> add_app_secret(access_token)
    Facebook.Graph.get(~s(/#{user_id}/permissions), fields)
  end

  @doc """
  Get the count of fans for the provided page_id

  ## Example
      iex> Facebook.fan_count("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page/
  """
  @spec fan_count(page_id :: integer | String.t, access_token) :: integer
  def fan_count(page_id, access_token) do
    page(page_id, access_token, ["fan_count"])
  end

  @doc """
  *Deprecated:* Please use fan_count instead.

  Get the count of fans for the provided page_id

  ## Example
      iex> Facebook.page_likes("CocaColaMx", "<Your Token>")

  See: https://developers.facebook.com/docs/graph-api/reference/page/
  """
  @spec page_likes(page_id :: integer | String.t, access_token) :: integer
  def page_likes(page_id, access_token) do
    fan_count(page_id, access_token)
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
      |> add_app_secret(access_token)
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
      iex> Facebook.page_feed(:posts, "CocaColaMx", "<Your Token>")
      iex> Facebook.page_feed(:tagged, "CocaColaMx", "<Your Token>", 55)
      iex> Facebook.page_feed(:promotable_posts, "CocaColaMx", "<Your Token>")
      iex> Facebook.page_feed(:feed, "CocaColaMx", "<Your Token>", 55, "id,name")

  See: https://developers.facebook.com/docs/graph-api/reference/page/feed
  """
  @spec page_feed(scope :: atom | String.t, page_id :: String.t, access_token, limit :: number, fields :: String.t) :: Map.t
  def page_feed(scope, page_id, access_token, limit \\ 25, fields \\ "") when limit <= 100 do
    params = [access_token: access_token, limit: limit, fields: fields]
      |> add_app_secret(access_token)

    {_, content} = Facebook.Graph.get(~s(/#{page_id}/#{scope}), params)

    content
  end

  @doc """
  Gets the number of elements that a scope has in a given object.

  An *object* stands for: post, comment, link, status update, photo.

  If you want to get the likes of a page, please see *fan_count*.

  Expected scopes:
    * :likes
    * :comments

  ## Example
      iex> Facebook.object_count(:likes, "1326382730725053_1326476257382367", "<Token>")
      2
      iex> Facebook.object_count(:comments, "1326382730725053_1326476257382367", "<Token>")
      2

  See: https://developers.facebook.com/docs/graph-api/reference/object/likes
  See: https://developers.facebook.com/docs/graph-api/reference/object/comments
  """
  @spec object_count(scope :: atom, object_id :: String.t, access_token) :: number
  def object_count(scope, object_id, access_token) when is_atom(scope) do
    params = [access_token: access_token, summary: true]
      |> add_app_secret(access_token)

    scp = scope
      |> Atom.to_string
      |> String.downcase

    Facebook.Graph.get(~s(/#{object_id}/#{scp}), params)
      |> get_summary
      |> summary_count
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
      iex> Facebook.object_count(:reaction, :wow, "769860109692136_1173416799336463", "<Token>")
      2
      iex> Facebook.object_count(:reaction, :haha, "769860109692136_1173416799336463", "<Token>")
      12
      iex> Facebook.object_count(:reaction, :thankful, "769860109692136_1173416799336463", "<Token>")
      33
  """
  @spec object_count(reaction, react_type :: atom, object_id :: String.t, access_token) :: number
  def object_count(:reaction, react_type, object_id, access_token) when is_atom(react_type) do
    type = react_type
      |> Atom.to_string
      |> String.upcase

    params = [access_token: access_token, type: type, summary: "total_count"]
      |> add_app_secret(access_token)

    Facebook.Graph.get(~s(/#{object_id}/reactions), params)
      |> get_summary
      |> summary_count
  end

  @doc """
  Get all the object reactions with single request.

  ## Examples
      iex> Facebook.object_count_all("769860109692136_1173416799336463", "<Token>")
      %{"angry" => 0, "haha" => 1, "like" => 0, "love" => 0, "sad" => 0, "wow" => 0}
  """
  @spec object_count_all(object_id :: String.t, access_token) :: map
  def object_count_all(object_id, access_token) do
    graph_query = """
    reactions.type(LIKE).summary(total_count).limit(0).as(like),
    reactions.type(LOVE).summary(total_count).limit(0).as(love),
    reactions.type(WOW).summary(total_count).limit(0).as(wow),
    reactions.type(HAHA).summary(total_count).limit(0).as(haha),
    reactions.type(SAD).summary(total_count).limit(0).as(sad),
    reactions.type(ANGRY).summary(total_count).limit(0).as(angry)
    """

    params = [access_token: access_token, fields: graph_query]
      |> add_app_secret(access_token)

    Facebook.Graph.get(~s(/#{object_id}), params)
      |> summary_count_all
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
    [ client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code ]
      |> get_access_token
  end

  @doc """
  Exchange a short lived access token for a long lived one

  ## Examples
      iex> Facebook.long_lived_access_token("client_id", "client_secret", "access_token")
      %{
        "access_token" => "ACCESS_TOKEN",
        "expires_in" => 5183976,
        "token_type" => "bearer"
      }

  See: https://developers.facebook.com/docs/facebook-login/access-tokens/expiration-and-extension
  """
  @spec long_lived_access_token(String.t, String.t, String.t) :: String.t
  def long_lived_access_token(client_id, client_secret, access_token) do
    [ grant_type: "fb_exchange_token",
      client_id: client_id,
      client_secret: client_secret,
      fb_exchange_token: access_token ]
      |> get_access_token
  end

  @doc """
  Get all test users for an app.

  The access token in this case needs to be an app access token.
  See:
    - https://developers.facebook.com/docs/facebook-login/access-tokens#apptokens
    - https://developers.facebook.com/docs/graph-api/reference/v2.8/app/accounts/test-users

  ## Examples
    iex> Facebook.test_users("appId", "appId|appSecret")
    [
      %{
        "access_token" => "ACCESS_TOKEN",
        "id" => "USER_ID",
        "login_url" => "https://developers.facebook.com/checkpoint/test-user-login/USER_ID/"
      }
    ]
  """
  @spec test_users(String.t, String.t) :: Map.t
  def test_users(app_id, access_token) do
    Facebook.Graph.get(
      ~s(/#{app_id}/accounts/test-users),
      [access_token: access_token]
    )
  end


  # Request access token and extract the access token from the access token
  # response
  defp get_access_token(params) do
    case Facebook.Graph.get(~s(/oauth/access_token), params) do
      {:error, error} -> {:error, error}
      {:ok, %{"summary" => summary}} -> summary
      {:ok, info_map} -> info_map
    end
  end

  # Provides the summary of a GET request when the 'summary' query parameter is
  # set to true.
  defp get_summary(summary_response) do
    case summary_response do
      {:error, error} -> {:error, error}
      {:ok, %{"summary" => summary}} -> summary
    end
  end

  # Gets the 'total_count' attribute from a summary request.
  defp summary_count(%{"total_count" => count}), do: count

  # Returns an error if the summary request fails.
  defp summary_count({:error, error}), do: {:error, error}

  defp summary_count_all({:ok, data}), do: summary_count_all(data)

  # Returns an error if the summary request fails.
  defp summary_count_all({:error, error}), do: {:error, error}

  # Calculate the reactions summary
  defp summary_count_all(summary) do
    Apex.ap summary
    Map.keys(summary)
      |> Enum.reject(fn(x) -> x === "id" end)
      |> Enum.map(fn(x) ->
        [x, get_in(summary[x], ["summary", "total_count"])] end)
      |> Enum.reduce(%{}, fn([name, count], acc) ->
        Map.put(acc, name, count) end)
  end

  # 'Encrypts' the token together with the app secret according to the guidelines of facebook.
  defp encrypt(token) do
    :crypto.hmac(:sha256, Config.appsecret, token)
    |> Base.encode16(case: :lower)
  end

  # Add the appsecret_proof to the GraphAPI request params if the app secret is
  # defined
  defp add_app_secret(params, access_token) do
    if !is_nil(Config.appsecret) do
      params ++ [appsecret_proof: encrypt(access_token)]
    else
      params
    end
  end
end
