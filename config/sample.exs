# Password generation options
config :passport, Passport.Hash,
  blocks: 2,
  cost: 160_000

# Authentication / session options
config :passport, Passport.Authenticate,
  session_ttl: 60 * 60 * 8

# Data storage adapter
config :passport, Passport.DataStore,
  adapter: Passport.DataStore.EctoAdapter

# Ecto data store adapter REQUIRED configuration
config :passport, Passport.DataStore.EctoAdapter,
  repo:   MyApp.Repo,
  schema: MyApp.User

# Ecto data store adapter optional configuration
config :passport, Passport.DataStore.EctoAdapter,
  id_field:                   :id,
  identity_field:             :username,
  password_field:             :password,
  email_field:                :email,
  password_reset_token_field: :password_reset_token,
  email_confirmed_field:      :email_confirmed

# Secret key to use for signing password reset JWTs (Required if using)
config :passport, Passport.ResetPassword,
    key: "USE_ENV_VARIABLE"

# Reset password options
config :passport, Passport.ResetPassword,
  timeout: 60 * 60 * 2

# Secret key to use for signing the email confirmation JWTs (Required if using)
config :passport, Passport.ConfirmEmail,
  key: "USE_ENV_VARIABLE"

# Confirm email options
config :passport, Passport.ResetPassword,
  timeout: 60 * 60 * 48
