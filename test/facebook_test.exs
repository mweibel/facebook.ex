defmodule FacebookTest do
  use ExUnit.Case

  @appId System.get_env("FBEX_APP_ID")
  @appSecret System.get_env("FBEX_APP_SECRET")
  # 19292868552 = facebook for developers page
  @pageId 19292868552

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
end
