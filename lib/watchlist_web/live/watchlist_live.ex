defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  import WatchlistWeb.Components

  alias Watchlist.Movies.Movie
  alias Watchlist.Movies.Queries
  alias WatchlistWeb.MovieFormComponent
  alias WatchlistWeb.MovieItemComponent

  @querable_keys ~w(title sort)
  @defult_query_params %{"sort" => "desc:title"}

  @impl true
  def render(assigns) do
    ~H"""
    <.movie_layout>
      <h1 class="text-center text-3xl font-bold mb-10">
        <%= gettext("Watchlist") %>
      </h1>

      <h2 class="text-left text-md font-bold mb-2"><%= gettext("Add new movie") %></h2>
      <.live_component
        module={MovieFormComponent}
        id="new-movie-form"
        movie={@movie}
        notify={fn type, movie -> send(self(), {type, movie}) end}
      />

      <h2 class="text-left text-md font-bold mt-10 mb-2"><%= gettext("Filter") %></h2>
      <div class="flex flex-col">
        <div class="rounded-lg border border-gray-300 px-6 py-5 mb-6">
          <.form for={@form} phx-change="query">
            <.input
              field={@form[:title]}
              type="text"
              placeholder={gettext("Title")}
              phx-debounce="300"
            />

            <.input field={@form[:sort]} type="hidden" />
          </.form>
        </div>

        <.button type="button" class="self-end" phx-click="sort">
          <%= gettext("Change order") %>
          <span :if={@query_params["sort"]}><%= humanized_sort(@query_params["sort"]) %></span>
        </.button>
      </div>

      <div
        class="grid grid-cols-1 gap-4 sm:grid-cols-1 mt-10"
        id="movies"
        phx-update="stream"
        phx-viewport-bottom="scroll"
      >
        <%= for {dom_id, movie} <- @streams.movies do %>
          <div id={dom_id}>
            <.live_component
              module={MovieItemComponent}
              movie={movie}
              id={dom_id}
              notify={fn type, movie -> send(self(), {type, movie}) end}
            />
          </div>
        <% end %>
      </div>
    </.movie_layout>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    query_params =
      params
      |> Map.get("query", @defult_query_params)
      |> Map.take(@querable_keys)

    page = Queries.Movie.default_page()
    movies = Queries.Movie.list(Map.put(query_params, "page", page))

    socket
    |> stream(:movies, movies, reset: true)
    |> assign(
      page: page,
      movie: %Movie{},
      form: to_form(query_params, as: :query),
      query_params: query_params
    )
    |> ok()
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    noreply(socket)
  end

  @impl true
  def handle_event("query", %{"query" => query_params}, socket) do
    movies = Queries.Movie.list(query_params)

    socket
    |> stream(:movies, movies, reset: true)
    |> assign(page: Queries.Movie.default_page(), query_params: query_params)
    |> push_to_watchlist(query_params)
    |> noreply()
  end

  @impl true
  def handle_event("sort", _params, socket) do
    query_params =
      case socket.assigns.query_params do
        %{"sort" => "asc:title"} = query_params -> Map.put(query_params, "sort", "desc:title")
        query_params -> Map.put(query_params, "sort", "asc:title")
      end

    movies = Queries.Movie.list(query_params)

    socket
    |> stream(:movies, movies, reset: true)
    |> assign(page: Queries.Movie.default_page(), query_params: query_params)
    |> push_to_watchlist(query_params)
    |> noreply()
  end

  @impl true
  def handle_event("scroll", _params, socket) do
    next_page = socket.assigns.page + 1
    query_params = socket.assigns.query_params
    movies = Queries.Movie.list(Map.put(query_params, "page", next_page))

    socket =
      Enum.reduce(movies, socket, fn movie, socket -> stream_insert(socket, :movies, movie) end)

    page =
      if(length(movies) < Queries.Movie.default_per_page(),
        do: socket.assigns.page,
        else: next_page
      )

    socket
    |> assign(:page, page)
    |> push_to_watchlist(query_params)
    |> noreply()
  end

  @impl true
  def handle_info({_, %Movie{} = _movie}, socket) do
    query_params = socket.assigns.query_params
    movies = Queries.Movie.list(query_params)

    socket
    |> stream(:movies, movies, reset: true)
    |> assign(page: Queries.Movie.default_page())
    |> push_to_watchlist(query_params)
    |> noreply()
  end

  defp push_to_watchlist(socket, query_params) do
    path = WatchlistWeb.Router.Helpers.watchlist_path(socket, :index, query: query_params)

    push_patch(socket, to: path)
  end

  defp humanized_sort("asc:title"), do: "#{gettext("Title")} #{gettext("descending")}"
  defp humanized_sort("desc:title"), do: "#{gettext("Title")} #{gettext("ascending")}"
  defp humanized_sort(_), do: nil
end
