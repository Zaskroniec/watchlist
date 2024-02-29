defmodule Watchlist.Movies.Actions.Movie do
  @moduledoc """
  Module contaning all functions related to Movie persistance
  """
  alias Watchlist.Movies.Movie
  alias Watchlist.Repo

  @spec create(Movie.t(), map()) :: {:ok, Movie.t()} | {:error, Ecto.Changeset.t()}
  def create(model, params) do
    model
    |> Movie.insert_changeset(params)
    |> Repo.insert()
  end

  @spec update(Movie.t(), map()) :: {:ok, Movie.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    model
    |> Movie.update_changeset(params)
    |> Repo.update()
  end

  @spec delete!(Movie.t()) :: Movie.t()
  def delete!(model) do
    Repo.delete!(model)
  end
end
