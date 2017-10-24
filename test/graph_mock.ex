defmodule Facebook.GraphMock do
  def me(:success) do
    JSON.encode(%{
      "id": "116331862460015", "first_name": "Open"
    })
  end

  def me(:error) do
    JSON.encode(%{"error": %{
      "message": "Invalid OAuth access token.",
      "type": "OAuthException",
      "code": 190,
      "fbtrace_id": "GB4fbEEGxkW"
    }})
  end

  def picture(:success) do
    JSON.encode(%{"data": %{
      "is_silhouette": true,
      "url": "https://scontent.xx.fbcdn.net/v/t1.0-1/s50x50/10354686_10150004552801856_220367501106153455_n.jpg?oh=90b508dc37562a01ebe9c7b9292b9a2f&oe=5A800C40"
    }})
  end

  def picture(:error) do
    JSON.encode(%{"error": %{
      "message": "Invalid OAuth access token.",
      "type": "OAuthException",
      "code": 190,
      "fbtrace_id": "GB4fbEEGxkW"
    }})
  end
end
