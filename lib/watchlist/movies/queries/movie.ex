defmodule Watchlist.Movies.Queries.Movie do
  @moduledoc """
  Module contaning all functions related to Movie table queries
  """
  import Ecto.Query

  alias Watchlist.Movies.Movie
  alias Watchlist.Repo

  @sort_keys ~w(title)
  @sort_directions ~w(desc asc)

  @spec list(map()) :: list(Movie.t())
  def list(params \\ %{}) do
    Movie
    |> visible_scope_filter()
    |> filter_by_title(params)
    |> sort_filter(params)
    |> Repo.all()
  end

  @spec get!(non_neg_integer()) :: Movie.t()
  def get!(id) do
    Movie
    |> visible_scope_filter()
    |> Repo.get!(id)
  end

  defp filter_by_title(query, %{"title" => title})
       when is_binary(title) and bit_size(title) > 0 do
    where(query, [movies: m], fragment("? ILIKE ?", m.title, ^"%#{title}%"))
  end

  defp filter_by_title(query, _params), do: query

  defp sort_filter(query, %{"sort" => sort}) when is_binary(sort) do
    case String.split(sort, ":") do
      [_, _] = sort_options -> sort_filter(query, sort_options)
      _ -> sort_filter(query, [])
    end
  end

  defp sort_filter(query, [direction, key] = _sort_options)
       when direction in @sort_directions and key in @sort_keys do
    order_by(query, [movies: m], [
      {^String.to_existing_atom(direction), field(m, ^String.to_existing_atom(key))}
    ])
  end

  defp sort_filter(query, _params), do: order_by(query, [movies: m], desc: m.title)

  defp visible_scope_filter(query) do
    query
    |> from(as: :movies)
    |> where([movies: m], m.watchlist_id == ^Movie.default_watchlist_id())
  end
end
