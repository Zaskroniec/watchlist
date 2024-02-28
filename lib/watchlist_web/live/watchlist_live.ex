defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  import WatchlistWeb.Components

  alias WatchlistWeb.MoveFormComponent
  alias Watchlist.Movies.{Movie, Queries}

  @impl true
  def render(assigns) do
    ~H"""
    <.movie_layout>
      <h1 class="text-center text-3xl font-bold mb-10">
        <%= gettext("Watchlist") %>
      </h1>

      <.live_component
        module={MoveFormComponent}
        id="new-movie-form"
        movie={@movie}
        notify={fn movie -> send(self(), {:movie_persisted, movie}) end}
      />

      <div class="grid grid-cols-1 gap-4 sm:grid-cols-1 mt-10" id="movies" phx-update="stream">
        <div
          :for={{dom_id, movie} <- @streams.movies}
          id={dom_id}
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
    |> assign(:movie, %Movie{})
    |> noreply()
  end

  @impl true
  def handle_info({:movie_persisted, %Movie{} = movie}, socket) do
    socket
    |> stream_insert(:movies, movie)
    |> noreply()
  end
end
