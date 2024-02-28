defmodule Watchlist.Factory do
  use ExMachina.Ecto, repo: Watchlist.Repo

  use Watchlist.MovieFactory
end
