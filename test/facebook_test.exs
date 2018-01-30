defmodule FacebookTest do
  use ExUnit.Case, async: false

  import Mock

  alias Facebook.GraphMock

  # Developer Notes:
  #
  # The following tests mock :hackney, don't be alarmed!
  # HTTPoison, the HTTP library that `Facebook.GraphAPI` is based off, is just
  # a wrapper for hackney. A request is delegated to hackney and the response
  # body is then processed by HTTPoison. `Facebook.GraphMock.mock_options/1`
  # provides a helper function to generate the request and body needed for
  # HTTPoison to do it's thing.
  #

  @app_id "123"
  @app_secret "456"
  @page_id 19292868552          # This is the facebook for developers page id
  @test_page_id 629965917187496 # `page_id` the test user created

  setup do
    [
      app_access_token: "#{@app_id}|#{@app_secret}",
      id: "116331862460015",
      access_token: "123",
      invalid_access_token: "123"
    ]
  end

  describe "me" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.me(:success) end
      ) do
        assert {:ok, user} = Facebook.me("id,first_name", access_token)
        assert(user["id"] == id)
        assert(String.length(user["first_name"]) > 0)
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, %{"code" => _,"message" => _,}} = Facebook.me(
          "id,first_name",
          invalid_access_token
        )
      end
    end
  end

  describe "my_accounts" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.my_accounts(:success) end
      ) do
        assert {:ok, %{"data" => [data | _]}} = Facebook.my_accounts(access_token)
        assert %{
          "access_token" => _,
          "id" => _,
          "category" => _,
          "name" => _,
          "perms" => _
        } = data
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, %{"code" => _,"message" => _,}} = Facebook.my_accounts(invalid_access_token)
      end
    end
  end

  describe "picture" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.picture(:success) end
      ) do
        {:ok, %{"data" => picture_data}} = Facebook.picture(
          id,
          "small",
          access_token
        )

        assert(String.length(picture_data["url"]) > 0)
      end
    end

    test "error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.picture(id, "small", invalid_access_token)
      end
    end
  end

  describe "publish" do
    test "feed - success", %{id: id, access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.publish(:success, :feed) end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.publish(:success, :image) end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.publish(:success, :image) end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.my_likes(:success) end
      ) do
        {:ok, likes_data} = Facebook.my_likes(access_token)

        assert(likes_data != nil)
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.my_likes(invalid_access_token)
      end
    end
  end

  describe "permissions" do
    test "success", %{id: id, access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.permissions(:success) end
      ) do
        assert {:ok, %{"data" => data}} = Facebook.permissions(id, access_token)

        [permission | _] = data
        assert(permission["permission"] != nil)
        assert(permission["status"] != nil)
      end
    end

    test "error", %{id: id, invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.permissions(id, invalid_access_token)
      end
    end
  end

  describe "fan_count" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.page(:success, :fan_count) end
      ) do
        assert {:ok, %{"fan_count" => _}} = Facebook.fan_count(
          @page_id,
          app_access_token
        )
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.fan_count(@page_id, invalid_access_token)
      end
    end
  end

  describe "page" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.page(:success) end
      ) do
        assert {:ok, %{
          "name" => name,
          "id" => id
        }} = Facebook.page(@page_id, app_access_token)

        assert(String.length(name) > 0)
        assert(id == Integer.to_string(@page_id, 10))
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.page(@page_id, invalid_access_token)
      end
    end
  end

  describe "page with fields" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.page(:success, :with_fields) end
      ) do
        assert {:ok, %{
          "id" => id,
          "about" => about
        }} = Facebook.page(@page_id, app_access_token, ["about"])

        assert(String.length(about) > 0)
        assert(id == Integer.to_string(@page_id, 10))
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.page(
          @page_id,
          invalid_access_token,
          ["about"]
        )
      end
    end
  end

  describe "page feed" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.page(:success, :feed) end
      ) do
        assert {:ok, %{"data" => [data | _]}} = Facebook.page_feed(
          :feed,
          @page_id,
          app_access_token,
          1
        )

        assert %{
          "id" => _,
          "created_time" => _,
          "message" => _,
          "story" => _
        } = data
      end
    end

    test "error", %{invalid_access_token: invalid_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.page_feed(
          :feed,
          @page_id,
          invalid_access_token,
          1
        )
      end
    end
  end

  describe "object count" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.object_count(:success, :likes) end
      ) do
        assert {:ok, 10} = Facebook.object_count(
          :likes,
          "1326382730725053_1326476257382367",
          access_token
        )
      end
    end
  end

  describe "object reaction count" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.object_count(:success, :likes) end
      ) do
        assert {:ok, 10} = Facebook.object_count(
          :reaction,
          :wow,
          "#{@test_page_id}_629967087187379",
          access_token
        )
      end
    end
  end

  describe "object count all" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.object_count_all(:success) end
      ) do
        assert {:ok, %{"haha" => haha, "love" => love}} = Facebook.object_count_all(
          "#{@test_page_id}_629967087187379",
          access_token
        )

        assert haha == 135
        assert love == 10
      end
    end
  end

  describe "long lived access token" do
    test "success", %{access_token: access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.long_lived_access_token(:success) end
      ) do
        assert {:ok, %{
          "access_token" => access_token,
          "expires_in" => expires_in,
          "token_type" => token_type
        }} = Facebook.long_lived_access_token(
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
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.error() end
      ) do
        assert {:error, _} = Facebook.long_lived_access_token(
          @app_id,
          @app_secret,
          invalid_access_token
        )
      end
    end
  end

  describe "new stream" do
    test "success", %{app_access_token: app_access_token} do
      with_mock :hackney, GraphMock.mock_options(
        fn(_) -> GraphMock.page(:success, :feed) end
      ) do
        posts = Facebook.page_feed(
          :feed,
          @page_id,
          app_access_token,
          1
        )
          |> Facebook.Stream.new
          |> Stream.take(1)
          |> Enum.to_list

        assert(length(posts) == 1)
      end
    end
  end
end
