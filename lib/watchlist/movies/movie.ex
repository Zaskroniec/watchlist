defmodule Watchlist.Movies.Movie do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @imdb_url_regex ~r{^https:\/\/www\.imdb\.com/title/tt.+$}
  @default_watchlist_id 1

  schema "movies" do
    field :title, :string
    field :imdb_url, :string
    field :watchlist_id, :integer
  end

  def default_watchlist_id(), do: @default_watchlist_id

  @spec insert_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def insert_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:title, :imdb_url])
    |> change(watchlist_id: @default_watchlist_id)
    |> validate_title()
    |> validate_imdb_url()
  end

  defp validate_title(changeset) do
    changeset
    |> ensure_trimmed(:title)
    |> validate_required([:title])
    |> validate_length(:title, min: 3, max: 240)
    |> unique_constraint([:title, :watchlist_id])
    |> unsafe_validate_unique([:title, :watchlist_id], Watchlist.Repo)
  end

  defp validate_imdb_url(changeset) do
    changeset
    |> ensure_trimmed(:imdb_url)
    |> validate_length(:imdb_url, max: 240)
    |> validate_change(:imdb_url, fn :imdb_url, imdb_url ->
      if Regex.match?(@imdb_url_regex, imdb_url) do
        []
      else
        [imdb_url: "should match format: https://www.imdb.com/title/tt<identifier>"]
      end
    end)
  end

  def ensure_trimmed(changeset, field) do
    case get_change(changeset, field) do
      nil -> changeset
      _ -> update_change(changeset, field, &String.trim/1)
    end
  end
end
