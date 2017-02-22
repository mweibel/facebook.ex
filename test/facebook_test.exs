defmodule FacebookTest do
  use ExUnit.Case

  @appId System.get_env("FBEX_APP_ID")
  @appSecret System.get_env("FBEX_APP_SECRET")

  setup_all do
  assert(@appId != nil)
    assert(@appSecret != nil)

    Facebook.Config.appsecret(@appSecret)

    [user | _] = Facebook.testUsers(@appId, ~s(#{@appId}|#{@appSecret}))

    assert(String.length(user["access_token"]) > 0)
    assert(String.length(user["id"]) > 0)
    assert(String.length(user["login_url"]) > 0)

    [test_user: user]
  end

  test "me", context do
    {:json, userData} = Facebook.me("id,first_name", context[:test_user]["access_token"])

    assert(userData["id"] == context[:test_user]["id"])
    assert(String.length(userData["first_name"]) > 0)
  end

  test "picture", context do
    {:json, pictureData} = Facebook.picture(context[:test_user]["id"], "small", context[:test_user]["access_token"])

    assert(String.length(pictureData["data"]["url"]) > 0)
  end

  test "myLikes", context do
    {:json, likesData} = Facebook.myLikes(context[:test_user]["access_token"])

    assert(likesData["data"] != nil)
  end
end
