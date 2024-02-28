defmodule Watchlist.MovieFactory do
  defmacro __using__(_opts) do
    quote do
      def movie_factory(attrs) do
        movie = %Watchlist.Movies.Movie{
          title: Faker.Superhero.name(),
          imdb_url: "https://www.imdb.com/title/tt#{Ecto.UUID.generate()}",
          watchlist_id: 1
        }

        movie
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
