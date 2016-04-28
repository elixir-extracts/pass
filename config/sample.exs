# Password generation options
config :pass, Pass.Hash,
  blocks: 2,
  cost: 160_000

# Authentication / session options
config :pass, Pass.Authenticate,
  session_ttl: 60 * 60 * 8

# Data storage adapter
config :pass, Pass.DataStore,
  adapter: Pass.DataStore.EctoAdapter

# Ecto data store adapter REQUIRED configuration
config :pass, Pass.DataStore.EctoAdapter,
  repo:   MyApp.Repo,
  schema: MyApp.User

# Ecto data store adapter optional configuration
config :pass, Pass.DataStore.EctoAdapter,
  id_field:                   :id,
  identity_field:             :username,
  password_field:             :password,
  email_field:                :email,
  password_reset_token_field: :password_reset_token,
  email_confirmed_field:      :email_confirmed

# Secret key to use for signing password reset JWTs (Required if using)
config :pass, Pass.ResetPassword,
    key: "USE_ENV_VARIABLE"

# Reset password options
config :pass, Pass.ResetPassword,
  timeout: 60 * 60 * 2

# Secret key to use for signing the email confirmation JWTs (Required if using)
config :pass, Pass.ConfirmEmail,
  key: "USE_ENV_VARIABLE"

# Confirm email options
config :pass, Pass.ResetPassword,
  timeout: 60 * 60 * 48
