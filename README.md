# Watchlist

## Requirements

* Elixir v1.15+
* Erlang 26.1+
* PostgreSQL 15.3+

## How to setup
1. Make sure you have the same DB config for postgres [config](/config/dev.exs) 
1. Run `mix setup`
1. Make sure all tests pass `mix test`
1. Verify code running static analysis `mix quality`
1. Start application by running `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Notes

- Based on requirements, all movies are scoped to `watchlist_id 1` to mimic associations. The same goes for factories.
- Core functionalities are split into submodules to avoid having one large module containing all persistence and query logic..

### LiveView

#### WatchlistWeb.WatchlistLive
This contains logic related to rendering and filtering a list of the movies.

#### WatchlistWeb.MovieItemComponent
This contains logic related to rendering single movie and loading edit mode.

#### WatchlistWeb.MovieFormComponent11
This contains logic related to mutating movies, whether they are new or existing structures.
Notify parent or another LiveView component about the updates in the structure.

### Task requirements

- [x] Infinity scroll
- [ ] Sortable position
- [x] Filtering/sorting
- [x] Rating & genre
- [x] Edit mode
- [ ] "Live" interactions

### Into

![Intro](/watchlist.png)