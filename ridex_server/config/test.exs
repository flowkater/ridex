import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ridex_server, RidexServer.Repo,
  username: "postgres",
  password: "password",
  hostname: "localhost",
  database: "ridex_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ridex_server, RidexServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "a1k3leL8av1OjQ8CWZ3W1GtTiGCyTjdwCCLaAwmcPbNXzU8ct+sXYc4PualhFl0Z",
  server: false

# In test we don't send emails.
config :ridex_server, RidexServer.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
