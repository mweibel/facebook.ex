  defmodule FacebookTest do
  use ExUnit.Case

  @appId System.get_env("FBEX_APP_ID")
  @appSecret System.get_env("FBEX_APP_SECRET")
  # 19292868552 = facebook for developers page
  @page_id 19292868552
  # 629965917187496 = page id the test user created
  @test_page_id 629965917187496

  setup_all do
    assert(@appId != nil)
    assert(@appSecret != nil)

    Facebook.setAppsecret(@appSecret)

    app_access_token = "#{@appId}|#{@appSecret}"

    {:ok, %{"data" => [user]}} = Facebook.test_users(@appId, app_access_token)

    assert(String.length(user["access_token"]) > 0)
    assert(String.length(user["id"]) > 0)
    assert(String.length(user["login_url"]) > 0)

    [
      app_access_token: app_access_token,
      id: user["id"],
      access_token: user["access_token"]
    ]
  end

  test "me", %{id: id, access_token: access_token} do
    assert {:ok, user} = Facebook.me("id,first_name", access_token)
    Apex.ap user

    assert(user["id"] == id)
    assert(String.length(user["first_name"]) > 0)
  end

  test "me - error" do
    assert {:error, %{
      "code" => _,
      "message" => _,
    }} = Facebook.me("id,first_name", "123")
  end

  test "picture", %{id: id, access_token: access_token} do
    {:ok, %{"data" => picture_data}} = Facebook.picture(id, "small", access_token)

    assert(String.length(picture_data["url"]) > 0)
  end

  test "publish", %{id: id, access_token: access_token} do

    {:ok, response} = Facebook.publish(:feed, id, [message: "test message", link: "www.example.org"], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "publish photo", %{id: id, access_token: access_token} do
    file_path = "test/assets/sample_image.png"

    {:ok, response} = Facebook.publish(:photo, id, file_path, [], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "publish video", %{id: id, access_token: access_token} do
   file_path = "test/assets/sample_video.mpg"

    {:json, response} = Facebook.publish(:video, id, file_path, [], access_token)
    assert(String.length(response["id"]) > 0)
  end

  test "my_likes", %{access_token: access_token} do
    {:ok, likes_data} = Facebook.my_likes(access_token)

    assert(likes_data != nil)
  end

  test "permissions", %{id: id, access_token: access_token} do
    {:ok, perms} = Facebook.permissions(id, access_token)

    assert(perms["data"] != nil)

    [ permission | _ ] = perms["data"]
    assert(permission["permission"] != nil)
    assert(permission["status"] != nil)
  end

  test "fan_count", %{app_access_token: app_access_token} do
    {:ok, %{"fan_count" => fan_count}} = Facebook.fan_count(
      @page_id,
      app_access_token
    )

    assert(fan_count > 0)
  end

  test "page_likes", %{app_access_token: app_access_token} do
    {:ok, %{"fan_count" => fan_count}} = Facebook.page_likes(
      @page_id,
      app_access_token
    )

    assert(fan_count > 0)
  end

  test "page", %{app_access_token: app_access_token} do
    {:ok, data} = Facebook.page(@page_id, app_access_token)

    assert %{"name" => name, "id" => id} = data
    assert(String.length(name) > 0)
    assert(id == Integer.to_string(@page_id, 10))
  end

  test "page with fields", %{app_access_token: app_access_token} do
    {:ok, data} = Facebook.page(@page_id, app_access_token, ["about"])

    assert %{"id" => id, "about" => about} = data
    assert(String.length(about) > 0)
    assert(id == Integer.to_string(@page_id, 10))
  end

  # TODO: returning {:error, error} atm
  test "page feed", %{access_token: access_token} do
    data = Facebook.page_feed(:feed, @test_page_id, access_token)
    Apex.ap data
    assert(data != nil)
  end

  # TODO: returning {:error, error} atm
  test "object count", %{access_token: access_token} do
    count = Facebook.object_count(:likes, "#{@test_page_id}_629967087187379", access_token)
    Apex.ap count
    assert(count >= 0)
  end

  # TODO: returning {:error, error} atm
  test "object reaction count", %{access_token: access_token} do
    count = Facebook.object_count(:reaction, :wow, "#{@test_page_id}_629967087187379", access_token)
    assert(count >= 0)
  end

  # TODO: returning {:error, error} atm
  test "object count all", %{access_token: access_token} do
    counts = Facebook.object_count_all("#{@test_page_id}_629967087187379", access_token)
    assert(counts["angry"] >= 0)
    assert(counts["haha"] >= 0)
    assert(counts["like"] >= 0)
    assert(counts["love"] >= 0)
    assert(counts["sad"] >= 0)
    assert(counts["wow"] >= 0)
  end

  test "long lived access token", %{access_token: access_token} do
    assert %{
      "access_token" => access_token,
      "expires_in" => expires_in,
      "token_type" => token_type
    } = Facebook.long_lived_access_token(
      @appId,
      @appSecret,
      access_token
    )

    assert(String.length(access_token) > 0)
    assert(token_type == "bearer")
    assert(expires_in > 0)
  end

  # TODO: a nil stream
  test "new stream", %{access_token: access_token} do
    stream =
      Facebook.page_feed(:feed, @test_page_id, access_token, 25)
      |> Facebook.Stream.new

    # get 150 posts
    posts = stream |> Stream.take(150) |> Enum.to_list

    assert(length(posts) == 150)
  end
end
