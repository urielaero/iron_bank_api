use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iron_bank, IronBank.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :iron_bank, IronBank.Repo,
  adapter: Mongo.Ecto,
  database: "iron_bank_test",
  pool_size: 1
