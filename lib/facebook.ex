defmodule Facebook do
  use Application
  use Supervisor

  @moduledoc """
  Provides API wrappers for the Facebook Graph API

  See: https://developers.facebook.com/docs/graph-api
  """

  alias Facebook.Config
  alias Facebook.Graph
  alias Facebook.GraphAPI
  alias Facebook.GraphVideoAPI
  alias Facebook.ResponseFormatter

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
      worker(Graph, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  @type using_appsecret :: boolean
  @type react_type :: atom
  @type scope :: atom | String.t
  @type reaction :: :reaction
  @type object_id :: String.t
  @type page_id :: String.t
  @type file_path :: String.t
  @type access_token :: String.t
  @type limit :: number
  @type fields :: list
  @type resp :: {:ok, Map.t} | {:error, Map.t}
  @type file_path :: String.t
  @type num_resp :: {:ok, number} | {:error, Map.t}

  @type params :: list
  @doc """
  If you want to use an appsecret proof, pass it into set_appsecret:

  ## Example
      iex> Facebook.set_appsecret("appsecret")

  See: https://developers.facebook.com/docs/graph-api/securing-requests
  """
  def set_appsecret(appsecret) do
    Config.appsecret(appsecret)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  ## Example
      iex> Facebook.me("id,first_name", "<Access Token>")
      {:ok, %{"first_name" => "...", "id" => "..."}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields :: String.t, access_token) :: resp
  def me(fields, access_token) when is_binary(fields) do
    me([fields: fields], access_token)
  end

  @doc """
  Basic user infos of the logged in user (specified by the access_token).

  ## Example
      iex> Facebook.me([fields: "id,first_name"], "<Access Token>")
      {:ok, %{"first_name" => "...", "id" => "..."}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/
  """
  @spec me(fields, access_token) :: resp
  def me(fields, access_token) do
    params = fields
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/me)
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
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
      {:ok, %{"id" => "{page_id}_{post_id}"}}

      iex> # publish a link and message
      iex> Facebook.publish(:feed, "<Feed Id>", [message: "<Message Body", link: "www.example.com"], "<Access Token>")
      {:ok, %{"id" => "{page_id}_{post_id}"}}

  """
  @spec publish(:feed, feed_id :: String.t, fields, access_token) :: resp
  def publish(:feed, feed_id, fields, access_token) do
    params = fields ++ [access_token: access_token]
    Graph.post("/#{feed_id}/feed", params, [])
  end

  @doc """
  Publish media to a feed. Author (user or page) is determined from the supplied token.

  The `feed_id` is the id for the user or page feed to publish to.
  Same :feed publishing permissions apply.

  ## Example
      iex> Facebook.publish(:photo, "<Feed Id>", "<Image Path>", [], "<Access Token>")
      {:ok, %{"id" => photo_id, "post_id" => "{page_id}_{post_id}"}

      iex> Facebook.publish(:video, "<Feed Id>", "<Video Path>", [], "<Access Token>")
      {:ok, %{"id" => video_id}

  See: https://developers.facebook.com/docs/pages/publishing#fotos_videos
  """
  @spec publish(:photo, page_id, file_path, params, access_token) :: resp
  def publish(:photo, page_id, file_path, params, access_token) do
    params = params
               |> add_access_token(access_token)
    payload = media_payload(file_path)

    ~s(/#{page_id}/photos)
      |> GraphAPI.post(payload, [], params: params)
      |> ResponseFormatter.format_response
  end

  @spec publish(:video, page_id, file_path, params, access_token, options :: list) :: resp
  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  def publish(:video, page_id, file_path, params, access_token, options \\ []) do
    params = params
               |> add_access_token(access_token)
    options = options ++ [params: params]
    payload = media_payload(file_path)

    ~s(/#{page_id}/videos)
      |> GraphVideoAPI.post(payload, [], options)
      |> ResponseFormatter.format_response
  end

  defp media_payload(file_path) do
    {
      :multipart,
      [{
        :file,
        file_path,
        {"form-data", [filename: Path.basename(file_path)]},
        []
      }]
    }
  end

  @doc """
  A Picture for a Facebook User

  ## Example
      iex> Facebook.picture("<Some Id>", "small", "<Access Token>")
      {:ok, %{"data": "..."}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/picture/
  """
  @spec picture(page_id, type :: String.t, access_token) :: resp
  def picture(page_id, type, access_token) do
    params = [type: type, redirect: false]
               |> add_access_token(access_token)
               |> add_app_secret(access_token)

    ~s(/#{page_id}/picture)
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
  end

  @doc """
  Likes of the currently logged in user (specified by the access_token)

  ## Example
      iex> Facebook.my_likes("<Access Token>")
      {:ok, %{"data" => [...]}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/likes
  """
  @spec my_likes(access_token) :: resp
  def my_likes(access_token) do
    params = []
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/me/likes)
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
  end

  @doc """
  Retrieves a list of granted permissions

  ## Example
      iex> Facebook.permissions("<Some Id>", "<Access Token>")
      {:ok, %{"data" => [%{"permission" => "...", "status" => "..."}]}}

  See: https://developers.facebook.com/docs/graph-api/reference/user/permissions
  """
  @spec permissions(user_id :: integer | String.t, access_token) :: resp
  def permissions(user_id, access_token) do
    fields = [access_token: access_token]
      |> add_app_secret(access_token)
    Graph.get(~s(/#{user_id}/permissions), fields)
  end

  @doc """
  Get the count of fans for the provided page_id

  ## Example
      iex> Facebook.fan_count("CocaColaMx", "<Access Token>")
      {:ok, %{"fan_count" => fan_count, "id" => id}}

  See: https://developers.facebook.com/docs/graph-api/reference/page/
  """
  @spec fan_count(page_id :: integer | String.t, access_token) :: integer
  def fan_count(page_id, access_token) do
    page(page_id, access_token, ["fan_count"])
  end

  @doc """
  Basic page information for the provided page_id

  ## Example
      iex> Facebook.page("CocaColaMx", "<Access Token>")
      {:ok, %{"id" => id, "name" => name}}

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token) :: resp
  def page(page_id, access_token) do
    page(page_id, access_token, [])
  end

  @doc """
  Get page information for the specified fields for the provided page_id

  ## Example
      iex> Facebook.page("CocaColaMx", "<Access Token>", "id")
      {:ok, %{"id" => id}

  See: https://developers.facebook.com/docs/graph-api/reference/page
  """
  @spec page(page_id :: integer | String.t, access_token, fields) :: resp
  def page(page_id, access_token, fields) do
    params = [fields: fields]
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/#{page_id})
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
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
      iex> Facebook.page_feed(:posts, "CocaColaMx", "<Access Token>")
      iex> Facebook.page_feed(:tagged, "CocaColaMx", "<Access Token>", 55)
      iex> Facebook.page_feed(:promotable_posts, "CocaColaMx", "<Access Token>")
      iex> Facebook.page_feed(:feed, "CocaColaMx", "<Access Token>", 55, "id,name")
      {:ok, %{"data" => [...]}}

  See: https://developers.facebook.com/docs/graph-api/reference/page/feed

  """
  # credo:disable-for-lines:2 Credo.Check.Readability.MaxLineLength
  @spec page_feed(scope, page_id, access_token, limit, fields :: String.t) :: resp
  def page_feed(scope, page_id, access_token, limit \\ 25, fields \\ "") when limit <= 100 do
    params = [limit: limit, fields: fields]
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/#{page_id}/#{scope})
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
  end

  @doc """
  Gets the number of elements that a scope has in a given object.

  An *object* stands for: post, comment, link, status update, photo.

  If you want to get the likes of a page, please see *fan_count*.

  Expected scopes:
    * :likes
    * :comments

  ## Example
      iex> Facebook.object_count(:likes, "1326382730725053_1326476257382367", "<Access Token>")
      {:ok, 10}
      iex> Facebook.object_count(:comments, "1326382730725053_1326476257382367", "<Access Token>")
      {:ok, 5}

  See: https://developers.facebook.com/docs/graph-api/reference/object/likes
  See: https://developers.facebook.com/docs/graph-api/reference/object/comments
  """
  @spec object_count(scope, object_id, access_token) :: num_resp
  def object_count(scope, object_id, access_token) when is_atom(scope) do
    params = [summary: true]
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    scp = scope
            |> Atom.to_string
            |> String.downcase

    ~s(/#{object_id}/#{scp})
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
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
      iex> Facebook.object_count(
        :reaction,
        :wow,
        "769860109692136_1173416799336463",
        "<Access Token>"
      )
      {:ok, 100}
  """
  @spec object_count(reaction, react_type, object_id, access_token) :: num_resp
  def object_count(:reaction, react_type, object_id, access_token) when is_atom(react_type) do
    type = react_type
             |> Atom.to_string
             |> String.upcase

    params = [type: type, summary: "total_count"]
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/#{object_id}/reactions)
      |> GraphAPI.get([], params: params)
      |> get_summary
      |> summary_count
  end

  @doc """
  Get all the object reactions with single request.

  ## Examples
      iex> Facebook.object_count_all("769860109692136_1173416799336463", "<Access Token>")
      {:ok, %{"angry" => 0, "haha" => 1, "like" => 0, "love" => 0, "sad" => 0, "wow" => 0}}
  """
  @spec object_count_all(object_id :: String.t, access_token) :: resp
  def object_count_all(object_id, access_token) do
    graph_query = """
    reactions.type(LIKE).summary(total_count).limit(0).as(like),
    reactions.type(LOVE).summary(total_count).limit(0).as(love),
    reactions.type(WOW).summary(total_count).limit(0).as(wow),
    reactions.type(HAHA).summary(total_count).limit(0).as(haha),
    reactions.type(SAD).summary(total_count).limit(0).as(sad),
    reactions.type(ANGRY).summary(total_count).limit(0).as(angry)
    """

    params = [fields: graph_query]
               |> add_app_secret(access_token)
               |> add_access_token(access_token)

    ~s(/#{object_id})
      |> GraphAPI.get([], params)
      |> summary_count_all
  end

  @doc """
  Exchange an authorization code for an access token

  ## Examples
      iex> Facebook.access_token("client_id", "client_secret", "redirect_uri", "code")
      {:ok, %{
        "access_token" => access_token,
        "expires_in" => 5183976,
        "token_type" => "bearer"
      }}

  See: https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow#confirm
  """
  @spec access_token(String.t, String.t, String.t, String.t) :: resp
  def access_token(client_id, client_secret, redirect_uri, code) do
    [
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      code: code
    ]
      |> get_access_token
  end

  @doc """
  Exchange a short lived access token for a long lived one

  ## Examples
      iex> Facebook.long_lived_access_token("client_id", "client_secret", "access_token")
      {:ok, %{
        "access_token" => access_token,
        "expires_in" => 5183976,
        "token_type" => "bearer"
      }}

  See: https://developers.facebook.com/docs/facebook-login/access-tokens/expiration-and-extension
  """
  @spec long_lived_access_token(String.t, String.t, String.t) :: resp
  def long_lived_access_token(client_id, client_secret, access_token) do
    [
      grant_type: "fb_exchange_token",
      client_id: client_id,
      client_secret: client_secret,
      fb_exchange_token: access_token
    ]
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
    {:ok, %{"data" => [
      %{
        "access_token" => "ACCESS_TOKEN",
        "id" => "USER_ID",
        "login_url" => "https://developers.facebook.com/checkpoint/test-user-login/USER_ID/"
      }
    ]}
  """
  @spec test_users(client_id, access_token) :: resp
  def test_users(client_id, access_token) do
    params = []
               |> add_access_token(access_token)
    ~s(/#{client_id}/accounts/test-users)
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
  end

  # Request access token and extract the access token from the access token
  # response
  defp get_access_token(params) do
    ~s(/oauth/access_token)
      |> GraphAPI.get([], params: params)
      |> ResponseFormatter.format_response
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
  defp summary_count(%{"total_count" => count}), do: {:ok, count}

  # Returns an error if the summary request fails.
  defp summary_count({:error, error}), do: {:error, error}

  defp summary_count_all({:ok, data}), do: summary_count_all(data)

  # Returns an error if the summary request fails.
  defp summary_count_all({:error, error}), do: {:error, error}

  # Calculate the reactions summary
  defp summary_count_all(summary) do
    summary
      |> Map.keys()
      |> Enum.reject(fn(x) -> x === "id" end)
      |> Enum.map(fn(x) ->
        [x, get_in(summary[x], ["summary", "total_count"])] end)
      |> Enum.reduce(%{}, fn([name, count], acc) ->
        Map.put(acc, name, count) end)
      |> (& {:ok, &1}).()
  end

  # 'Encrypts' the token together with the app secret according to the
  # guidelines of facebook.
  defp encrypt(token) do
    :sha256
      |> :crypto.hmac(Config.appsecret, token)
      |> Base.encode16(case: :lower)
  end

  # Add the appsecret_proof to the GraphAPI request params if the app secret is
  # defined
  defp add_app_secret(params, access_token) do
    if is_nil(Config.appsecret) do
      params
    else
      params ++ [appsecret_proof: encrypt(access_token)]
    end
  end

  ## Add access_token to params
  defp add_access_token(fields, token) do
    fields ++ [access_token: token]
  end
end
