defmodule Watchlist.Movies.MovieTest do
  use Watchlist.DataCase, async: true

  alias Watchlist.Movies.Movie

  describe "insert_changeset/2" do
    test "returns valid changeset for given params" do
      params = %{
        "title" => "Star Wars",
        "imdb_url" => "https://www.imdb.com/title/tt0120915",
        "genre" => "action",
        "rate" => 9
      }

      changeset = Movie.insert_changeset(%Movie{}, params)

      assert changeset.valid?
    end

    test "ensures trimmed params" do
      params = %{"title" => "Star Wars ", "imdb_url" => "https://www.imdb.com/title/tt0120915 "}
      changeset = Movie.insert_changeset(%Movie{}, params)

      assert changeset.valid?
      assert "Star Wars" == Ecto.Changeset.get_change(changeset, :title)

      assert "https://www.imdb.com/title/tt0120915" ==
               Ecto.Changeset.get_change(changeset, :imdb_url)
    end

    test "validates required params" do
      changeset = Movie.insert_changeset(%Movie{})

      refute changeset.valid?

      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates correctness of `genre`" do
      params = %{"genre" => "invalid"}

      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{genre: ["is invalid"]} = errors_on(changeset)
    end

    test "validates rate range" do
      params = %{"rate" => -1}

      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{rate: ["must be greater than or equal to 1"]} = errors_on(changeset)

      params = %{"rate" => 11}

      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{rate: ["must be less than or equal to 10"]} = errors_on(changeset)
    end

    test "validates length for given params" do
      params = %{
        "title" => Faker.Lorem.sentence(50),
        "imdb_url" => "https://www.imdb.com/title/tt0120915#{Faker.Lorem.sentence(50)}"
      }

      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{
               title: ["should be at most 240 character(s)"],
               imdb_url: ["should be at most 240 character(s)"]
             } = errors_on(changeset)
    end

    test "validates correctness of `imdb_url` format" do
      params = %{"imdb_url" => "https://www.imdb.com/title/t}"}

      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{imdb_url: ["should match format: https://www.imdb.com/title/tt<identifier>"]} =
               errors_on(changeset)
    end

    test "validates title uniqueness for given" do
      movie = insert(:movie, title: "Antman")

      params = %{"title" => movie.title}
      changeset = Movie.insert_changeset(%Movie{}, params)

      refute changeset.valid?

      assert %{title: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
