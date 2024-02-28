defmodule Watchlist.Movies.Actions.Movie do
  alias Watchlist.Repo
  alias Watchlist.Movies.Movie

  @spec create(Movie.t(), map()) :: {:ok, Movie.t()} | {:error, Ecto.Changeset.t()}
  def create(model, params) do
    model
    |> Movie.insert_changeset(params)
    |> Repo.insert()
  end
end
