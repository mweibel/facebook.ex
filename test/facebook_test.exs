defmodule FacebookTest do
  use ExUnit.Case

  @appId System.get_env("FBEX_APP_ID")
  @appSecret System.get_env("FBEX_APP_SECRET")
  # 19292868552 = facebook for developers page
  @pageId 19292868552
  # 629965917187496 = page id the test user created
  @testPageId 629965917187496

  setup_all do
    assert(@appId != nil)
    assert(@appSecret != nil)

    Facebook.setAppsecret(@appSecret)

    appAccessToken = "#{@appId}|#{@appSecret}"

    [user | _] = Facebook.testUsers(@appId, appAccessToken)

    assert(String.length(user["access_token"]) > 0)
    assert(String.length(user["id"]) > 0)
    assert(String.length(user["login_url"]) > 0)

    [
      app_access_token: appAccessToken,
      id: user["id"],
      access_token: user["access_token"]
    ]
  end

  test "me", context do
    %{id: id, access_token: access_token} = context

    {:json, userData} = Facebook.me("id,first_name", access_token)

    assert(userData["id"] == id)
    assert(String.length(userData["first_name"]) > 0)
  end

  test "picture", context do
    %{id: id, access_token: access_token} = context

    {:json, pictureData} = Facebook.picture(id, "small", access_token)

    assert(String.length(pictureData["data"]["url"]) > 0)
  end

  test "publish", context do
    %{id: id, access_token: access_token} = context

    {:json, response} = Facebook.publish(:feed, id, [message: "test message", link: "www.example.org"], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "publish photo", context do
    %{id: id, access_token: access_token} = context
    file_path = "test/assets/sample_image.png"

    {:json, response} = Facebook.publish(:photo, id, file_path, [], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "publish video", context do
    %{id: id, access_token: access_token} = context
    file_path = "test/assets/sample_video.mpg"

    {:json, response} = Facebook.publish(:video, id, file_path, [], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "myLikes", context do
    %{access_token: access_token} = context

    {:json, likesData} = Facebook.myLikes(access_token)

    assert(likesData["data"] != nil)
  end

  test "permissions", context do
    %{id: id, access_token: access_token} = context

    {:json, perms} = Facebook.permissions(id, access_token)

    assert(perms["data"] != nil)

    [ permission | _ ] = perms["data"]
    assert(permission["permission"] != nil)
    assert(permission["status"] != nil)
  end

  test "fanCount", context do
    %{app_access_token: app_access_token} = context

    count = Facebook.fanCount(@pageId, app_access_token)
    assert(count > 0)
  end

  test "pageLikes", context do
    %{app_access_token: app_access_token} = context

    count = Facebook.pageLikes(@pageId, app_access_token)
    assert(count > 0)
  end

  test "page", context do
    %{app_access_token: app_access_token} = context

    {:json, data} = Facebook.page(@pageId, app_access_token)
    assert(data != nil)

    %{"name" => name, "id" => id} = data
    assert(String.length(name) > 0)
    assert(id == Integer.to_string(@pageId, 10))
  end

  test "page with fields", context do
    %{app_access_token: app_access_token} = context

    {:json, data} = Facebook.page(@pageId, app_access_token, ["about"])
    assert(data != nil)

    %{"id" => id, "about" => about} = data
    assert(String.length(about) > 0)
    assert(id == Integer.to_string(@pageId, 10))
  end

  test "page feed", context do
    %{access_token: access_token} = context

    data = Facebook.pageFeed(:feed, @testPageId, access_token)
    assert(data != nil)
  end

  test "object count", context do
    %{access_token: access_token} = context

    count = Facebook.objectCount(:likes, "#{@testPageId}_629967087187379", access_token)
    assert(count >= 0)
  end

  test "object reaction count", context do
    %{access_token: access_token} = context

    count = Facebook.objectCount(:reaction, :wow, "#{@testPageId}_629967087187379", access_token)
    assert(count >= 0)
  end

  test "object count all", context do
    %{access_token: access_token} = context

    counts = Facebook.objectCountAll("#{@testPageId}_629967087187379", access_token)
    assert(counts["angry"] >= 0)
    assert(counts["haha"] >= 0)
    assert(counts["like"] >= 0)
    assert(counts["love"] >= 0)
    assert(counts["sad"] >= 0)
    assert(counts["wow"] >= 0)
  end

  test "long lived access token", context do
    %{access_token: access_token} = context
    data = Facebook.longLivedAccessToken(@appId, @appSecret, access_token)

    assert(String.length(data["access_token"]) > 0)
    assert(data["token_type"] == "bearer")
    assert(data["expires"] > 0)
  end

  test "new stream", context do
    %{access_token: access_token} = context

    stream =
      Facebook.pageFeed(:feed, @testPageId, access_token, 25)
      |> Facebook.Stream.new

    # get 150 posts
    posts = stream |> Stream.take(150) |> Enum.to_list

    assert(length(posts) == 150)
  end
end
