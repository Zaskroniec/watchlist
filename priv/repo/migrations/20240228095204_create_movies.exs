defmodule Watchlist.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string, null: false
      add :imdb_url, :string
      add :watchlist_id, :bigint, null: false
    end

    create index(:movies, :watchlist_id)
    create unique_index(:movies, [:title, :watchlist_id])
  end
end
