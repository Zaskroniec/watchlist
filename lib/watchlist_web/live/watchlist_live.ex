defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  import WatchlistWeb.Components

  alias WatchlistWeb.MoveFormComponent
  alias Watchlist.Movies.{Movie, Actions, Queries}

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
        module={MoveFormComponent}
        id="new-movie-form"
        movie={@movie}
        notify={fn movie -> send(self(), {:movie_persisted, movie}) end}
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
          Change order
          <span :if={@query_params["sort"]}><%= humanized_sort(@query_params["sort"]) %></span>
        </.button>
      </div>

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
            <.button
              type="button"
              class="ml-3"
              phx-click={JS.push("delete") |> JS.hide(to: "##{dom_id}")}
              phx-value-id={movie.id}
            >
              Delete
            </.button>
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
    query_params = Map.get(params, "query", @defult_query_params)
    movies = Queries.Movie.list(query_params)

    socket
    |> stream(:movies, movies, reset: true)
    |> assign(
      movie: %Movie{},
      form: to_form(query_params, as: :query),
      query_params: query_params
    )
    |> noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    deleted_movie =
      id
      |> Queries.Movie.get!()
      |> Actions.Movie.delete!()

    socket
    |> stream_delete(:movies, deleted_movie)
    |> noreply()
  end

  @impl true
  def handle_event("query", %{"query" => params}, socket) do
    push_to_watchlist(socket, params)
  end

  @impl true
  def handle_event("sort", _params, socket) do
    query_params =
      case socket.assigns.query_params do
        %{"sort" => "asc:title"} = query_params -> Map.put(query_params, "sort", "desc:title")
        query_params -> Map.put(query_params, "sort", "asc:title")
      end

    push_to_watchlist(socket, query_params)
  end

  @impl true
  def handle_info({:movie_persisted, %Movie{} = movie}, socket) do
    query_params = socket.assigns.query_params

    if query_params == @defult_query_params do
      socket
      |> stream_insert(:movies, movie)
      |> noreply()
    else
      push_to_watchlist(socket, query_params)
    end
  end

  defp push_to_watchlist(socket, query_params) do
    path = WatchlistWeb.Router.Helpers.watchlist_path(socket, :index, query: query_params)

    socket
    |> push_patch(to: path)
    |> noreply()
  end

  defp humanized_sort("asc:title"), do: "#{gettext("Title")} #{gettext("descending")}"
  defp humanized_sort("desc:title"), do: "#{gettext("Title")} #{gettext("ascending")}"
  defp humanized_sort(_), do: nil
end
