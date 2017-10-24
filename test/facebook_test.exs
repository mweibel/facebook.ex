defmodule FacebookTest do
  use ExUnit.Case, async: false

  import Mock

  @app_id System.get_env("FBEX_APP_ID")
  @app_secret System.get_env("FBEX_APP_SECRET")
  # 19292868552 = facebook for developers page
  @page_id 19292868552
  # 629965917187496 = page id the test user created
  @test_page_id 629965917187496

  setup do
    assert(@app_id != nil)
    assert(@app_secret != nil)

    Facebook.setAppsecret(@app_secret)

    app_access_token = "#{@app_id}|#{@app_secret}"

    {:ok, %{"data" => [user]}} = Facebook.test_users(@app_id, app_access_token)

    assert(String.length(user["access_token"]) > 0)
    assert(String.length(user["id"]) > 0)
    assert(String.length(user["login_url"]) > 0)

    [
      app_access_token: app_access_token,
      id: user["id"],
      access_token: user["access_token"],
      invalid_access_token: "123"
    ]
  end

  describe "me" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.me(:success) end
      ] do
        assert {:ok, user} = Facebook.me("id,first_name", access_token)
        assert(user["id"] == id)
        assert(String.length(user["first_name"]) > 0)
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, %{"code" => _,"message" => _,}} = Facebook.me(
          "id,first_name",
          invalid_access_token
        )
      end
    end
  end

  describe "picture" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.picture(:success) end
      ] do
        {:ok, %{"data" => picture_data}} = Facebook.picture(
          id,
          "small",
          access_token
        )

        assert(String.length(picture_data["url"]) > 0)
      end
    end

    test "error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.picture(id, "small", invalid_access_token)
      end
    end
  end

  describe "publish" do
    test "feed - success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.publish(:success, :feed) end
      ] do
        {:ok, response} = Facebook.publish(
          :feed,
          id,
          [message: "test message",
          link: "www.example.org"],
          access_token
        )
        assert(String.length(response["id"]) > 0)
      end
    end

    test "feed - error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.publish(
          :feed,
          id,
          [message: "test message",
          link: "www.example.org"],
          invalid_access_token
        )
      end
    end

    test "photo - success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.publish(:success, :image) end
      ] do
        file_path = "test/assets/sample_image.png"
        assert {:ok, %{"id" => _, "post_id" => _}} = Facebook.publish(
          :photo,
          id,
          file_path,
          [],
          access_token
        )
      end
    end

    test "photo - error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        file_path = "test/assets/sample_image.png"
        assert {:error, _} = Facebook.publish(
          :photo,
          id,
          file_path,
          [],
          invalid_access_token
        )
      end
    end

    test "video - success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.publish(:success, :image) end
      ] do
        file_path = "test/assets/sample_video.mpg"
        assert {:ok, response} = Facebook.publish(
          :video,
          id,
          file_path,
          [],
          access_token
        )
        assert(String.length(response["id"]) > 0)
      end
    end

    test "video - error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        file_path = "test/assets/sample_image.png"
        assert {:error, _} = Facebook.publish(
          :photo,
          id,
          file_path,
          [],
          invalid_access_token
        )
      end
    end
  end

  describe "my_likes" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.my_likes(:success) end
      ] do
        {:ok, likes_data} = Facebook.my_likes(access_token)

        assert(likes_data != nil)
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.my_likes(invalid_access_token)
      end
    end
  end

  describe "permissions" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.permissions(:success) end
      ] do
        assert {:ok, %{"data" => data}} = Facebook.permissions(id, access_token)

        [permission | _] = data
        assert(permission["permission"] != nil)
        assert(permission["status"] != nil)
      end
    end

    test "error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.permissions(id, invalid_access_token)
      end
    end
  end

  describe "fan_count" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.page(:success, :fan_count) end
      ] do
        assert {:ok, %{"fan_count" => _}} = Facebook.fan_count(
          @page_id,
          app_access_token
        )
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.fan_count(@page_id, invalid_access_token)
      end
    end
  end

  describe "page_likes" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.page(:success, :fan_count) end
      ] do
        assert {:ok, %{"fan_count" => _}} = Facebook.page_likes(
          @page_id,
          app_access_token
        )
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.page_likes(@page_id, invalid_access_token)
      end
    end
  end

  describe "page" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.page(:success) end
      ] do
        assert {:ok, %{
          "name" => name,
          "id" => id
        }} = Facebook.page(@page_id, app_access_token)

        assert(String.length(name) > 0)
        assert(id == Integer.to_string(@page_id, 10))
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.page(@page_id, invalid_access_token)
      end
    end
  end

  describe "page with fields" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.page(:success, :with_fields) end
      ] do
        assert {:ok, %{
          "id" => id,
          "about" => about
        }} = Facebook.page(@page_id, app_access_token, ["about"])

        assert(String.length(about) > 0)
        assert(id == Integer.to_string(@page_id, 10))
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.page(
          @page_id,
          invalid_access_token,
          ["about"]
        )
      end
    end
  end

  test "page feed", %{access_token: access_token} do
    data = Facebook.page_feed(:feed, @test_page_id, access_token)
    assert(data != nil)
  end

  test "object count", %{access_token: access_token} do
    count = Facebook.object_count(:likes, "#{@test_page_id}_629967087187379", access_token)
    assert(count >= 0)
  end

  test "object reaction count", %{access_token: access_token} do
    count = Facebook.object_count(:reaction, :wow, "#{@test_page_id}_629967087187379", access_token)
    assert(count >= 0)
  end

  test "object count all", %{access_token: access_token} do
    counts = Facebook.object_count_all("#{@test_page_id}_629967087187379", access_token)
    assert(counts["angry"] >= 0)
    assert(counts["haha"] >= 0)
    assert(counts["like"] >= 0)
    assert(counts["love"] >= 0)
    assert(counts["sad"] >= 0)
    assert(counts["wow"] >= 0)
  end

  describe "long lived access token" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.long_lived_access_token(:success) end
      ] do
        assert %{
          "access_token" => access_token,
          "expires_in" => expires_in,
          "token_type" => token_type
        } = Facebook.long_lived_access_token(
          @app_id,
          @app_secret,
          access_token
        )

        assert(String.length(access_token) > 0)
        assert(token_type == "bearer")
        assert(expires_in > 0)
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, [
        request: fn(_method, _url, _headers, _payload, _options) ->
          {:ok, nil, nil, nil}
        end,
        body: fn(_) -> Facebook.GraphMock.error() end
      ] do
        assert {:error, _} = Facebook.long_lived_access_token(
          @app_id,
          @app_secret,
          invalid_access_token
        )
      end
    end
  end

  test "new stream", %{access_token: access_token} do
    stream =
      Facebook.page_feed(:feed, @test_page_id, access_token, 25)
      |> Facebook.Stream.new

    # get 150 posts
    posts = stream |> Stream.take(150) |> Enum.to_list

    assert(length(posts) == 150)
  end
end

defmodule Facebook.GraphMock do
  def error() do
    JSON.encode(%{"error": %{
      "message": "Invalid OAuth access token.",
      "type": "OAuthException",
      "code": 190,
      "fbtrace_id": "GB4fbEEGxkW"
    }})
  end

  def long_lived_access_token(:success) do
    JSON.encode(%{
      "access_token" => "access_token",
      "expires_in" => 5184000,
      "token_type" => "bearer"
    })
  end

  def my_likes(:success) do
    JSON.encode(%{
      "data": []
    })
  end

  def me(:success) do
    JSON.encode(%{
      "id": "116331862460015", "first_name": "Open"
    })
  end

  def page(:success) do
    JSON.encode(%{
      "id": "19292868552", "name": "Facebook for Developers"
    })
  end

  def page(:success, :with_fields) do
    JSON.encode(%{
      "id": "19292868552",
      "about": "Build, grow, and monetize your app with Facebook."
    })
  end

  def page(:success, :fan_count) do
    JSON.encode(%{
      "id": "19292868552", "fan_count": 5469088
    })
  end

  def permissions(:success) do
    JSON.encode(%{"data": [%{
      "permission": "user_friends",
      "status": "granted"
    }]})
  end

  def picture(:success) do
    JSON.encode(%{"data": %{
      "is_silhouette": true,
      "url": "https://scontent.xx.fbcdn.net/..."
    }})
  end

  def publish(:success, :feed) do
    JSON.encode(%{
      "id": "116331862460015_120732275353308",
    })
  end

  def publish(:success, :image) do
    JSON.encode(%{
      "id": "120752462017955",
      "post_id": "116331862460015_120752105351324"
    })
  end

  def publish(:success, :video) do
    JSON.encode(%{
      "id": "120762398683628",
    })
  end
end
