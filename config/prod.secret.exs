use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :iron_bank, IronBank.Endpoint,
  secret_key_base: "C2kK+FwDJbNKrcf6iFULZ529/srOoyuXg04lvsT6b9+O8wuDiS2nC5ht+NFDSb7V"

# Configure your database
config :iron_bank, IronBank.Repo,
  adapter: Mongo.Ecto,
  database: "iron_bank_prod",
  pool_size: 20
