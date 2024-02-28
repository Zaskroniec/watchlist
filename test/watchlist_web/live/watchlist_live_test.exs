defmodule WatchlistWeb.WatchlistLiveTest do
  use WatchlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Watchlist.Movies.Movie

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

    test "renders page with form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#new--movie-form")
    end

    test "renders form errors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view
             |> form("#new--movie-form")
             |> render_change(%{movie: %{title: "a"}}) =~ "should be at least 3 character"
    end

    test "submits new movie and renders in the list", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#new--movie-form", movie: %{title: "Riddick"})
      |> render_submit()

      view = render(view)

      assert %Movie{title: "Riddick"} = movie = Watchlist.Repo.one(Movie)

      assert view =~ movie.title
    end

    test "deletes movie form the list", %{conn: conn} do
      movie = insert(:movie)

      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ movie.title

      view
      |> element("#movies-#{movie.id} div #delete-movies-#{movie.id}")
      |> render_click()

      view = render(view)

      refute view =~ movie.title
    end

    test "filters movie list", %{conn: conn} do
      movie_1 = insert(:movie, title: "Star Wars")
      movie_2 = insert(:movie, title: "Lord of the rings")

      {:ok, _view, html} = live(conn, ~p"/?query[title]=#{movie_1.title}")

      assert html =~ movie_1.title

      refute html =~ movie_2.title
    end

    test "opens edit mode in movie and updates item in the list", %{conn: conn} do
      movie = insert(:movie, title: "Star Wars", genre: :action)

      {:ok, view, html} = live(conn, ~p"/")

      assert html =~ movie.title

      view
      |> element("#movies-#{movie.id} div #edit-movies-#{movie.id}")
      |> render_click()

      html =
        view
        |> form("#edit-#{movie.id}-movie-form", movie: %{title: "Riddick"})
        |> render_submit()

      assert html =~ "Riddick"
    end
  end
end
