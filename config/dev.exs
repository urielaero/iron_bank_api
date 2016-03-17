use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :iron_bank, IronBank.Endpoint,
  http: [port: 5000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :iron_bank, IronBank.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :iron_bank, IronBank.Repo,
  adapter: Mongo.Ecto,
  database: "iron_bank_dev",
  #hostname: "10.9.8.14", # for vpn
  pool_size: 10


config :iron_bank, cn_admin: "cn=admin,dc=openstack,dc=org",
                   cn_password: "password",
                   ldap_context: "ou=Users,dc=openstack,dc=org"

#config for vpn
#config :iron_bank, cn_admin: "cn=admin,dc=test,dc=com",
#                   cn_password: "antony",
#                   ldap_context: "ou=usuarios,dc=test,dc=com",
#                   ldap_host: "10.9.8.10"


config :iron_bank, mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
                   mailgun_key: System.get_env("MAILGUN_KEY")

config :iron_bank, mailer_api: Util.Mailer,
                   ldap_api: Util.GenLdap.InMemory,
                   token_api: Phoenix.Token

config :iron_bank, :http_front, "http://localhost:8080"
