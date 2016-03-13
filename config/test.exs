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

config :iron_bank, cn_admin: "cn=admin,dc=openstack,dc=org",
                   cn_password: "password",
                   ldap_context: "ou=Users,dc=openstack,dc=org"

#config :iron_bank, cn_admin: "cn=admin,dc=test,dc=com",
#                   cn_password: "antony",
#                   ldap_context: "ou=Users,dc=test,dc=com",
#                   ldap_host: "10.9.8.10"

config :iron_bank, mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
                   mailgun_key: System.get_env("MAILGUN_KEY")

config :iron_bank, mailer_api: Util.Mailer.InMemory,
                   ldap_api: Util.GenLdap.InMemory,
                   token_api: Util.PlugAuthTokenTest

config :iron_bank, :http_front, "http://localhost:4000"
