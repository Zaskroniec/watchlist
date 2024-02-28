defmodule Watchlist.Repo do
  use Ecto.Repo,
    otp_app: :watchlist,
    adapter: Ecto.Adapters.Postgres
end
