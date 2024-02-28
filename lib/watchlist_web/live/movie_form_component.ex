defmodule WatchlistWeb.MovieFormComponent do
  use WatchlistWeb, :live_component

  alias Watchlist.Movies.{Movie, Actions, Queries}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id={"#{@action}-#{@movie.id}-movie-form"}
      >
        <div class="flex justify-between items-center rounded-lg border border-gray-300 px-6 py-5">
          <div class="flex-1 mr-10">
            <.input
              id={"#{@form[:title].id}-#{@movie.id}"}
              field={@form[:title]}
              type="text"
              placeholder={gettext("Title")}
              phx-debounce="blur"
            />
            <.input
              id={"#{@form[:imdb_url].id}-#{@movie.id}"}
              field={@form[:imdb_url]}
              type="text"
              placeholder={gettext("Imdb url")}
              phx-debounce="blur"
            />
            <.input
              id={"#{@form[:rate].id}-#{@movie.id}"}
              field={@form[:rate]}
              type="number"
              placeholder={gettext("7")}
              phx-debounce="blur"
              min="1"
              max="10"
              step="1"
            />
            <.input
              id={"#{@form[:genre].id}-#{@movie.id}"}
              field={@form[:genre]}
              type="select"
              prompt={gettext("Select")}
              options={genre_options()}
            />
          </div>

          <%= if @action == :new do %>
            <.button phx-disable-with={gettext("Adding...")}><%= gettext("Add movie") %></.button>
          <% else %>
            <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {action, changeset} =
      case assigns.movie do
        %Movie{id: id} = movie when is_number(id) ->
          {:edit, Movie.update_changeset(movie)}

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

  defp handle_validate(socket, :edit, params) do
    changeset =
      socket.assigns.movie
      |> Movie.update_changeset(params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:form, to_form(changeset))
    |> noreply()
  end

  defp handle_save(socket, :new, params) do
    case Actions.Movie.create(socket.assigns.movie, params) do
      {:ok, movie} ->
        socket.assigns.notify.(:movie_persisted, movie)

        socket
        |> assign(:form, to_form(Movie.insert_changeset(%Movie{})))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp handle_save(socket, :edit, params) do
    movie = Queries.Movie.get!(socket.assigns.movie.id)

    case Actions.Movie.update(movie, params) do
      {:ok, movie} ->
        socket.assigns.notify.(:movie_persisted, movie)

        socket
        |> assign(movie: movie, form: to_form(Movie.update_changeset(movie)))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp genre_options() do
    [
      {gettext("action"), :action},
      {gettext("drama"), :drama},
      {gettext("triller"), :triller},
      {gettext("horror"), :horror},
      {gettext("comedy"), :comedy}
    ]
  end
end
