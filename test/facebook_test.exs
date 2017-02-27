defmodule FacebookTest do
  use ExUnit.Case

  @appId System.get_env("FBEX_APP_ID")
  @appSecret System.get_env("FBEX_APP_SECRET")

  setup_all do
    assert(@appId != nil)
    assert(@appSecret != nil)

    Facebook.setAppsecret(@appSecret)

    [user | _] = Facebook.testUsers(@appId, ~s(#{@appId}|#{@appSecret}))

    assert(String.length(user["access_token"]) > 0)
    assert(String.length(user["id"]) > 0)
    assert(String.length(user["login_url"]) > 0)

    [id: user["id"], access_token: user["access_token"]]
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

end
