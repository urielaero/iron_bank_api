ExUnit.start
ExUnit.configure(exclude: [:skip, :genldap_api, :mailer])
# mix test --include genldap_api

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
