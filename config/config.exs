# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :pass, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:pass, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

if Mix.env == :test do
  # Print only warnings and errors during test
  config :logger, level: :warn

  # Configure your database
  config :pass, Pass.Test.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "postgres",
    database: "pass_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

  # Let's keep tests fast with quick passwords
  config :pass, Pass.Hash,
    blocks: 1,
    cost: 1

  config :pass, Pass.DataStore.EctoAdapter,
    repo:   Pass.Test.Repo,
    schema: Pass.Test.User,
    password_reset_token_field: :passwordResetToken,
    email_confirmed_field:      :emailConfirmed

  config :pass, Pass.ResetPassword,
    key: "aaod82fjalv02444nod82fjalv02444n"

  config :pass, Pass.ConfirmEmail,
    key: "aaod82fjalv02444nod82fjalv02444n"
end
