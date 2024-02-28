defmodule Watchlist.Movies.Queries.Movie do
  @moduledoc """
  Module contaning all functions related to Movie table queries
  """
  import Ecto.Query

  alias Watchlist.Movies.Movie
  alias Watchlist.Repo

  @spec list(map()) :: list(Movie.t())
  def list(_params \\ %{}) do
    Movie
    |> visible_scope_filter()
    |> Repo.all()
  end

  @spec get!(non_neg_integer()) :: Movie.t()
  def get!(id) do
    Movie
    |> visible_scope_filter()
    |> Repo.get!(id)
  end

  defp visible_scope_filter(query) do
    query
    |> from(as: :movies)
    |> where([movies: m], m.watchlist_id == ^Movie.default_watchlist_id())
  end
end
