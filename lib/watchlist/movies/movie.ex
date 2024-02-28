defmodule Watchlist.Movies.Movie do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "movies" do
    field :title, :string
    field :imdb_url, :string
    field :watchlist_id, :integer
  end
end
