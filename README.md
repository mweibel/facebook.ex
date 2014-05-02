# facebook.ex

Facebook Graph API Wrapper written in Elixir.
Please note, this is very much a work in progress. Feel free to contribute using pull requests.

## Installation

### mix.exs

* Clone repo  
* `Run mix deps.get`  
* To give it a try, run `iex -S mix`  
  
```
{:facebook,"0.0.4",[github: "mweibel/facebook.ex"]}
```

Visit [hex.pm/packages/facebook](https://hex.pm/packages/facebook) or
[expm.co/facebook](http://expm.co/facebook) for package manager infos.

## API

### Facebook.me([fields: "yourfields"], "access_token", options \\ []) -> {:json, data}
Basic user infos of the logged in user (specified by the access_token). /1 takes either a list or string.

### Facebook.myLikes(access_token, options \\ []) -> {:json, data}
Likes of the currently logged in user (specified by the access_token)  
  
### Facebook.set_appsecret(appsecret) -> {:ok}
[Facebook recommends securing requests using an appsecret proof.](https://developers.facebook.com/docs/graph-api/securing-requests)
Set the appsecret if you would like to do so.