defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  import WatchlistWeb.Components

  alias WatchlistWeb.{MovieItemComponent, MovieFormComponent}
  alias Watchlist.Movies.{Movie, Queries}

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

      <div class="grid grid-cols-1 gap-4 sm:grid-cols-1 mt-10" id="movies">
        <.live_component
          :for={movie <- @movies}
          module={MovieItemComponent}
          movie={movie}
          id={"movies-#{movie.id}"}
          notify={fn type, movie -> send(self(), {type, movie}) end}
        />
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
    |> assign(
      movies: movies,
      movie: %Movie{},
      form: to_form(query_params, as: :query),
      query_params: query_params
    )
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
  def handle_info({_, %Movie{} = _movie}, socket) do
    push_to_watchlist(socket, socket.assigns.query_params)
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
