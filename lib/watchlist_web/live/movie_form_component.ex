defmodule WatchlistWeb.MoveFormComponent do
  use WatchlistWeb, :live_component

  alias Watchlist.Movies.{Movie, Actions}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="new-movie-form"
      >
        <div class="flex justify-between items-center rounded-lg border border-gray-300 px-6 py-5">
          <div class="flex-1 mr-10">
            <.input
              field={@form[:title]}
              type="text"
              placeholder={gettext("Title")}
              phx-debounce="blur"
            />
            <.input
              field={@form[:imdb_url]}
              type="text"
              placeholder={gettext("Imdb url")}
              phx-debounce="blur"
            />
          </div>

          <.button phx-disable-with={gettext("Adding...")}>Add movie</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {action, changeset} =
      case assigns.movie do
        %Movie{id: id} when is_number(id) ->
          {:edit, :noop}

        movie ->
          {:new, Movie.insert_changeset(movie)}
      end

    socket
    |> assign(
      form: to_form(changeset),
      action: action,
      movie: assigns.movie,
      notify: assigns.notify
    )
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"movie" => params}, socket) do
    handle_validate(socket, socket.assigns.action, params)
  end

  @impl true
  def handle_event("save", %{"movie" => params}, socket) do
    handle_save(socket, socket.assigns.action, params)
  end

  defp handle_validate(socket, :new, params) do
    changeset =
      socket.assigns.movie
      |> Movie.insert_changeset(params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:form, to_form(changeset))
    |> noreply()
  end

  defp handle_save(socket, :new, params) do
    case Actions.Movie.create(socket.assigns.movie, params) do
      {:ok, movie} ->
        socket.assigns.notify.(movie)

        socket
        |> assign(:form, to_form(Movie.insert_changeset(%Movie{})))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
