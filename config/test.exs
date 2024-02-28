import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :watchlist, Watchlist.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "watchlist_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :watchlist, WatchlistWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "VVeNAaPz/qTMESxe/QYQIAE2qT2+2lURt6m7FbxXF+28pfBfMMy/6xhxc8XX7HKA",
  server: false

# In test we don't send emails.
config :watchlist, Watchlist.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
