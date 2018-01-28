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

  def object_count(:success, :likes) do
    JSON.encode(%{"summary" => %{
      "total_count" => 10
    }})
  end

  def object_count_all(:success) do
    JSON.encode(%{
      "haha" => %{"summary" => %{"total_count" => 135}},
      "love" => %{"summary" => %{"total_count" => 10}}
    })
  end

  def page(:success) do
    JSON.encode(%{
      "id": "19292868552", "name": "Facebook for Developers"
    })
  end

  def page(:success, :feed) do
    JSON.encode(%{"data": [%{
      "created_time" => "2017-01-01T01:05:49+0000",
      "id" => "915520981811232_1894726877223966",
      "message" => "https://www.facebook.com/notes/...",
      "story" => ""
    }]})
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

  def payment(:success, :no_fields) do
    JSON.encode(%{
      "id": "11639730386596",
      "created_time": "2018-01-28T00:33:19+0000",
    })
  end

  def payment(:success, :with_fields) do
    JSON.encode(%{
      "request_id": "A76449",
      "id": "11639730386596",
      "actions": [
        %{
          "type": "charge",
          "status": "completed",
          "currency": "EUR",
          "amount": "11.99",
          "time_created": "2018-01-28T00:33:19+0000",
          "time_updated": "2018-01-28T00:33:20+0000",
          "tax_amount": "2.08"
        }
      ],
      "payout_foreign_exchange_rate": 1.2308349
    })
  end

  def dispute(:success) do
    JSON.encode(%{
      "success": true
    })
  end

  def refunds(:success) do
    JSON.encode(%{
      "success": true
    })
  end

  def mock_options(body_function) do
    [
      request: request(),
      body: body_function,
    ]
  end

  defp request do
    fn(_method, _url, _headers, _payload, _options) ->
      {:ok, nil, nil, nil}
    end
  end

end
