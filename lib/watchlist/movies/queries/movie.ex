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
    |> from(as: :movies)
    |> where([movies: m], m.watchlist_id == ^Movie.default_watchlist_id())
    |> Repo.all()
  end
end
