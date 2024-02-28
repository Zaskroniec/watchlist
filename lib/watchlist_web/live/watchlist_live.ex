defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  import WatchlistWeb.Components

  alias Watchlist.Movies.Queries

  @impl true
  def render(assigns) do
    ~H"""
    <.movie_layout>
      <h1 class="text-center text-3xl font-bold mb-10">
        <%= gettext("Watchlist") %>
      </h1>

      <div class="grid grid-cols-1 gap-4 sm:grid-cols-1" id="movies" phx-update="stream">
        <div
          :for={{dom_id, movie} <- @streams.movies}
          id={"movie-#{dom_id}"}
          class="flex items-center justify-between relative space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400"
        >
          <div class="capitalize">
            <%= movie.title %>
          </div>
          <div class="flex items-center">
            <a
              :if={movie.imdb_url}
              href={movie.imdb_url}
              target="blank"
              rel="noreferrer"
              class="underline"
            >
              Imdb
            </a>
            <.button type="button" class="ml-3">Delete</.button>
          </div>
        </div>
      </div>
    </.movie_layout>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    ok(socket)
  end

  @impl true
  def handle_params(params, _uri, socket) do
    movies = Queries.Movie.list(params)

    socket
    |> stream(:movies, movies)
    |> noreply()
  end
end
