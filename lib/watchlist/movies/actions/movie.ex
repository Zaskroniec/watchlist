defmodule Watchlist.Movies.Actions.Movie do
  alias Watchlist.Repo
  alias Watchlist.Movies.Movie

  @spec create(Movie.t(), map()) :: {:ok, Movie.t()} | {:error, Ecto.Changeset.t()}
  def create(model, params) do
    model
    |> Movie.insert_changeset(params)
    |> Repo.insert()
  end

  @spec delete!(Movie.t()) :: Movie.t()
  def delete!(model) do
    Repo.delete!(model)
  end
end
