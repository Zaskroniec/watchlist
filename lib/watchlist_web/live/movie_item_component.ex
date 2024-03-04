defmodule WatchlistWeb.MovieItemComponent do
  use WatchlistWeb, :live_component

  alias Watchlist.Movies.Actions
  alias Watchlist.Movies.Queries
  alias WatchlistWeb.MovieFormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        :if={@edit_mode}
        module={MovieFormComponent}
        id={"edit-#{@id}"}
        movie={@movie}
        notify={
          fn type, movie ->
            send_update(@myself, movie: movie, edit_mode: false, id: @id, notify: @notify)
            @notify.(type, movie)
          end
        }
      />

      <div
        :if={not @edit_mode}
        class="flex items-center justify-between relative space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400"
      >
        <div class="capitalize">
          <%= @movie.title %>
        </div>
        <div class="flex items-center">
          <a
            :if={@movie.imdb_url}
            href={@movie.imdb_url}
            target="_blank"
            rel="noopener noreferrer"
            class="underline"
          >
            <%= gettext("Imdb") %>
          </a>
          <.button
            id={"edit-#{@id}"}
            type="button"
            class="ml-3"
            phx-click="edit_mode"
            phx-target={@myself}
          >
            <%= gettext("Edit") %>
          </.button>
          <.button
            id={"delete-#{@id}"}
            type="button"
            class="ml-3"
            phx-click={JS.push("delete") |> JS.hide(to: "##{@id}")}
            phx-value-id={@movie.id}
            phx-target={@myself}
          >
            <%= gettext("Delete") %>
          </.button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(movie: assigns.movie, id: assigns.id, edit_mode: false, notify: assigns.notify)
    |> ok()
  end

  @impl true
  def handle_event("edit_mode", _params, socket) do
    socket
    |> assign(:edit_mode, true)
    |> noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    deleted_movie =
      id
      |> Queries.Movie.get!()
      |> Actions.Movie.delete!()

    socket.assigns.notify.(:movie_deleted, deleted_movie)

    noreply(socket)
  end
end
