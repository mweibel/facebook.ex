# facebook.ex

[![Build Status](https://travis-ci.org/mweibel/facebook.ex.svg?branch=master)](https://travis-ci.org/mweibel/facebook.ex)

Facebook Graph API Wrapper written in Elixir.

## Installation

Add facebook.ex as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [{:facebook, "~> 0.7.0"}]
end
```

After you are done, run this in your shell to fetch the new dependency:

```bash
$ mix deps.get
```

## Usage

1. Register an application on [developer.facebook.com](https://developer.facebook.com)
2. Get the access token from the settings page of your registered application

Then you can get started with code.

Start an iex shell in your project folder:

```bash
$ iex -S mix
```

Then try some API calls:

```
iex(1)> Facebook.me("first_name", "ACCESSTOKEN")

14:31:18.720 [info]  [get] https://graph.facebook.com/v2.6/me?fields=first_name&access_token=ACCESSTOKEN [] ""

14:31:19.128 [info]  body: "{\"first_name\":\"Michael\"}"

{:json, %{"first_name" => "Michael"}} # <--- that's the return value

iex(2)> Facebook.objectCount(:likes, "262588213843476_801732539929038", "ACCESSTOKEN")

14:34:16.435 [info]  [get] https://graph.facebook.com/v2.6/262588213843476_801732539929038/likes?access_token=ACCESSTOKEN&summary=true [] ""

14:34:16.629 [info]  body: "{\"data\":[..somedata..],\"summary\":{\"total_count\":48,\"can_like\":true,\"has_liked\":false}}"

48 # <--- that's the return value
```

## API Documentation

See [API Documentation for facebook.ex](http://hexdocs.pm/facebook/).

