# facebook.ex

[![Build Status](https://travis-ci.org/mweibel/facebook.ex.svg?branch=master)](https://travis-ci.org/mweibel/facebook.ex)

Facebook Graph API Wrapper written in Elixir. ([documentation](http://hexdocs.pm/facebook/))

## Installation

Add facebook.ex as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [{:facebook, "~> 0.17.0"}]
end
```

After you are done, run this in your shell to fetch the new dependency:

```bash
$ mix deps.get
```

## Configuration

```
config :facebook,
  appsecret: "<your app secret>",
  graph_url: "https://graph.facebook.com",
  graph_video_url: "https://graph-video.facebook.com"
```
For graph_url and video_graph_url, you may also specify versioned urls (recommended) to pin your calls to a specific API version, like so:
```
  graph_url: "https://graph.facebook.com/v2.11",
  graph_video_url: "https://graph-video.facebook.com/v2.8"
```
Note that you *must not* end the urls with a slash or the requests will fail (Facebook will report an error about unknown url components)!

Supplying an appsecret is optional. If you supply it, an [appsecret_proof](https://developers.facebook.com/docs/graph-api/securing-requests) will be submitted along with the Graph API requests. The appsecret can be changed (or set) at runtime using `Facebook.set_appsecret("<app secret>")`.

## Usage

1. Register an application on [developer.facebook.com](https://developer.facebook.com)
2. Get an `access_token` from [Facebook's Access Token Tool](https://developers.facebook.com/tools/accesstoken/)

Then you can get started with code.

Start an iex shell in your project folder:

```bash
$ iex -S mix
```

Then try some API calls:

```
iex(1)> Facebook.me("first_name", "ACCESSTOKEN")
{:ok, %{"first_name" => "Michael"}} # <--- that's the return value

iex(2)> Facebook.object_count(:likes, "262588213843476_801732539929038", "ACCESSTOKEN")
{:ok, 48} # <--- that's the return value
```

## Contributing
We encourage contribution from anyone! If you've got an improvement to the documentation or feature you've implemented, please open a [pull request](https://github.com/mweibel/facebook.ex/pulls).
This project uses [credo](https://github.com/rrrene/credo) for code analysis. Running `mix credo` will give you a nice output which will tell you if any of the changes you've made aren't consistent with the rest of our codebase.

The Facebook Graph API is fairly large and as such we're not using every facet of it, so if you're not seeing an edge that is handled, please report an [issue](https://github.com/mweibel/facebook.ex/issues) or open a [pull request](https://github.com/mweibel/facebook.ex/pulls) to add it.
