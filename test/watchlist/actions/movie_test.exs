defmodule Watchlist.Movies.Actions.MovieTest do
  use Watchlist.DataCase, async: true

  alias Watchlist.Movies.Actions
  alias Watchlist.Movies.Movie

  describe "create/2" do
    test "returns created movie for given params" do
      params = %{"title" => "Star Wars"}

      assert {:ok, %Movie{}} = Actions.Movie.create(%Movie{}, params)
    end

    test "returns errors for given params" do
      params = %{}

      assert {:error, %Ecto.Changeset{}} = Actions.Movie.create(%Movie{}, params)
    end
  end

  describe "update/2" do
    setup do
      movie = insert(:movie, title: "Diune")

      {:ok, movie: movie}
    end

    test "returns updated movie for given params", %{movie: movie} do
      params = %{"title" => "Star Wars"}

      assert {:ok, movie} = Actions.Movie.update(movie, params)

      assert %Movie{title: "Star Wars"} = movie
    end

    test "returns errors for given params", %{movie: movie} do
      params = %{"title" => nil}

      assert {:error, %Ecto.Changeset{}} = Actions.Movie.update(movie, params)
    end
  end

  describe "delete!/1" do
    test "deletes movie" do
      movie = insert(:movie)

      assert movie = Actions.Movie.delete!(movie)
      assert :deleted = Ecto.get_meta(movie, :state)
    end
  end
end
