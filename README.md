# facebook.ex

[![Build Status](https://travis-ci.org/mweibel/facebook.ex.svg?branch=master)](https://travis-ci.org/mweibel/facebook.ex)

Facebook Graph API Wrapper written in Elixir. ([documentation](http://hexdocs.pm/facebook/))

## Installation

Add facebook.ex as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [{:facebook, "~> 0.18.0"}]
end
```

After you are done, run this in your shell to fetch the new dependency:

```bash
$ mix deps.get
```

## Configuration

You can configure facebook.ex in your mix `config.exs` (or, if you're using the Phoenix Framework, in your `config/dev.exs|test.exs|prod.exs`, respectively) with the following keys, which state the library defaults:
```
config :facebook,
  app_id: nil,
  app_secret: nil,
  app_access_token: nil,
  graph_url: "https://graph.facebook.com",
  graph_video_url: "https://graph-video.facebook.com"
```
For graph_url and video_graph_url, Facebook automatically uses the oldest active Graph API version available if you don't specify a version in the url. You may use versioned urls to pin your calls to a specific API versions (recommended), e.g. like so:
```
  graph_url: "https://graph.facebook.com/v2.11",
  graph_video_url: "https://graph-video.facebook.com/v2.8"
```
Note that you *must not* end the urls with a slash or the requests will fail (Facebook will report an error about unknown url components)!

`app_id`, `app_secret` and `app_access_token` do not need to be supplied if you are using no Graph API calls that require them (e.g. payment calls).
If you supply the `app_secret`, an [appsecret_proof](https://developers.facebook.com/docs/graph-api/securing-requests) will be submitted along with the Graph API requests. The app_secret can be changed (or set) at runtime using `Facebook.set_app_secret("<app secret>")`.

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
