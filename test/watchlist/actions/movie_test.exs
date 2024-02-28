defmodule Watchlist.Movies.Actions.MovieTest do
  use Watchlist.DataCase, async: true

  alias Watchlist.Movies.{Movie, Actions}

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
end
