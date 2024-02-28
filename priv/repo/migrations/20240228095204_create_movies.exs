defmodule Watchlist.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    create table(:movies) do
      add :title, :string, null: false
      add :imdb_url, :string
      add :watchlist_id, :bigint, null: false
      add :genre, :string
      add :rate, :integer
    end

    create index(:movies, :watchlist_id)
    create unique_index(:movies, [:title, :watchlist_id])

    execute """
      CREATE INDEX movies_title_gin_trgm_idx
        ON movies
        USING gin (title gin_trgm_ops);
    """
  end

  def down do
    drop table(:movies)
  end
end
