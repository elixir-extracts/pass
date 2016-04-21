# Passport

Passport is a simple authentication manager for Plug applications. The goal for
Passport is to create a highly configurable library that ships with sensible
defaults. It provides password hashing, user credential authentication, and user
session authentication. While support for using Ecto is built-in to the library,
it is designed to be storage-framework agnostic.


## Requirements

Since Passport is an authentication manager for [Plug][plug], the Plug library
is required. Passport tracks a user's authentication status using
`Plug.Session`'s session storage. This means that `Plug.Conn.fetch_session/2`
needs to be called before authentication information can be accessed.


## Installation

Passport can be installed from Hex - just add passport to your list of
dependencies in `mix.exs`:

    def deps do
      [{:passport, "~> 0.1"}]
    end


## Quick Start

If you are using Ecto, you will need to configure the
`Passport.DataStore.EctoAdapter` module with the repository and schema it should
use. Add something like the following to your "confix.exs" file:

```elixir
config :passport, Passport.DataStore.EctoAdapter,
  repo:   MyApp.Repo,
  schema: MyApp.User
```

If you aren't using Ecto, you will need to specify which module to use for data
storage calls like this:

```elixir
config :passport, Passport.DataStore,
  adapter: MyApp.CustomDataStoreAdapter
```

Whataver you are using for data storage, you will want to make sure to update it
to use `Passport.Hash.db_password/1` to generate the hashed and formatted
password string for storage.

Finally, to get session authentication working, add
`Passport.Plugs.authenticate_session/2` to your plug list after the
`Plug.Conn.fetch_session/2` plug. If you are using [Phoenix][phoenix], your
`router.ex` file might look something like this:

```elixir
defmodule MyApp.Router do
  use MyApp.Web, :router
  import Passport.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :authenticate_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # ...
end
```

## Limitations

Right now, only PBKDF2 with SHA512 is supported for hashing passwords. Also,
instead of setting a desired derived key length, Passport instead allows for
setting the number of blocks to use. (The derived key length is then a multiple
of the hash size. For example, the derived key length for 1 block of SHA512 is
64 bytes while 2 blocks is 128 bytes.) In case we decide to change this in the
future, please don't configure more than 7 blocks.


## License

Passport source code is released under Apache 2.0 License. Check LICENSE file
for more information.


[plug]: https://github.com/elixir-lang/plug
[phoenix]: http://www.phoenixframework.org
