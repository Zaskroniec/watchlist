defmodule WatchlistWeb.WatchlistLiveTest do
  use WatchlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Live :index" do
    test "renders page with empty movie list", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ "Watchlist"

      refute has_element?(view, "#movies .flex")
    end

    test "render page with movie list", %{conn: conn} do
      [movie_1, movie_2, movie_3] = insert_list(3, :movie)

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Watchlist"

      assert html =~ movie_1.title
      assert html =~ movie_2.title
      assert html =~ movie_3.title
    end
  end
end
