defmodule Facebook.Stream do
  alias Facebook.Graph

  @moduledoc """
  Provides stream functionalities for the Facebook Graph API paginated responses

  See: https://developers.facebook.com/docs/graph-api/using-graph-api/#reading
  """

  defstruct [:current, :next, :max_retries]

  @type retry :: pos_integer
  @type error :: any

  @doc """
  Build a stream resource from a facebook paginated response with a custom
  define error handler and a maximum of retries

  The user defined error handler can be used to log errors, delay next retry,
  raise an exception, etc.  The default error handler only sleeps by 1 second.

  ## Examples
  iex> stream = Facebook.pageFeed(:feed, "CocaColaMx", "<Your Token>", "id,name") |> Facebook.Stream.new
  iex> stream |> Stream.filter( name == "Coca Cola") |> Stream.take(100) |> Enum.to_list

  # Custom error handler with linear backoff
  iex> feed = Facebook.pageFeed(:feed, "CocaColaMx", "<Your Token>", "id,name")
  iex> stream = Facebook.Stream.new(feed, fn(error, retry) -> Process.sleep(retry*500) end)
  iex> stream |> Stream.filter( name == "Coca Cola") |> Stream.take(100) |> Enum.to_list
  """
  @spec new(Map.t, ((error, retry) -> any), pos_integer) :: Enumerable.t
  def new(paged_response,
    error_handler \\ fn(_error, _retry) -> Process.sleep(1_000) end,
    max_retries \\ 3) do
    Stream.resource(
      fn -> %__MODULE__{next: paged_response, current: :empty, max_retries: max_retries} end,
      fn(feed) -> case nextPage(feed, error_handler) do
		    %__MODULE__{current: nil   }   -> {:halt, nil} # no more data
		    %__MODULE__{current: response} -> {getData(response), %{feed | current: response}} # normal pagination
		    {error, retries} -> # max retries reached
		      error_handler.(error, retries)
		      {:halt, error}
		  end
      end,
      fn (_) -> :ok
      end
    )
  end

  # Get next object using FB Graph API pagination
  defp nextPage(%__MODULE__{current: :empty, next: next} = feed,
    _error_handler) do
    %{feed | current: next, next: :empty}
  end

  defp nextPage(%__MODULE__{current: current, max_retries: max_retries} = feed,
    error_handler) do
    Stream.cycle([1])
    |> Stream.scan(0, &(&1+&2))
    |> Enum.reduce_while(feed, fn i, acc ->
      if i < max_retries do
	case getNextPagedData(current) do
	  {:json, next_obj} -> {:halt, %{feed | current: next_obj}}
	  nil               -> {:halt, %{feed | current: nil}}
	  {:error, reason}  -> error_handler.(reason, i); {:cont, reason}
	end
      else
	{:halt, {acc, i}}
      end
    end)
  end

  # Gets next data page
  defp getNextPagedData(%{"paging" => %{"next" => next_url}}) do
    Graph.request(:get, next_url, [])
  end

  defp getNextPagedData(%{"paging" => %{"cursors" => %{"next" => next_url}}}) do
    Graph.request(:get, next_url, [])
  end

  defp getNextPagedData(_), do: nil

  # Get data from FB Graph Object
  defp getData(%{"data" => data}), do: data
  defp getData(_), do: nil

end
