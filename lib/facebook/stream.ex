defmodule Facebook.Stream do
  alias Facebook.Graph

  @moduledoc """
  Provides stream functionalities for the Facebook Graph API paginated responses

  See: https://developers.facebook.com/docs/graph-api/using-graph-api/#reading
  """


  defstruct [:current, :next]

  @doc """
  Build a stream resource from a facebook paginated response

  ## Examples
  iex> stream = Facebook.pageFeed(:feed, "CocaColaMx", "<Your Token>", "id,name") |> Facebook.Stream.new
  iex> stream |> Stream.filter( name == "Coca Cola") |> Stream.take(100) |> Enum.to_list
  """
  @spec new(Map.t) :: Enumerable.t
  def new(paged_response) do
    Stream.resource(
      fn -> %__MODULE__{next: paged_response, current: :empty} end,
      fn(feed) -> case nextPage(feed) do
		    %__MODULE__{current: nil   }   -> {:halt, nil}
		    %__MODULE__{current: response} -> {getData(response), %{feed | current: response}}
		  end
      end,
      fn(_) -> :ok end
    )
  end


  # Get next object using FB Graph API pagination
  defp nextPage(%__MODULE__{current: :empty, next: next} = feed) do
    %{feed | current: next, next: :empty}
  end

  defp nextPage(%__MODULE__{current: current} = feed) do
    case getNextPagedData(current) do
      {:json, next_obj} -> %{feed | current: next_obj}
      {:error, _} -> defaultError(feed)
      nil -> %{feed | current: nil}
    end
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

  # Default error handler, sleeps and retries
  defp defaultError(feed) do
    Process.sleep(1_000)
    nextPage(feed)
  end

end
