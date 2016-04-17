# Password generation options
config :passport, Passport.Hash,
  blocks: 2,
  cost: 160_000

# Authentication / session options
config :passport, Passport.Authenticate,
  session_ttl: 60 * 60 * 8
