# Change Log

## Unreleased

### Added

- The ability to skip looking up the user in the data storage when using the
  `require_authentication` plug. (This was accidentaly the default behavior in
  previous releases.)

- The `require_authentication` plug now stashes the current user data in the
  connection with `assign(:current_user)`.

### Fixed

- When using the `require_authentication` plug, it now checks that the user
  hasn't been deleted from the data store.


## 0.1.1  (2016-04-20)

### Added

- Documentation and overview in the README
- Doc comments for all public modules and functions
- The `:content_type` and `:body` options for 401 responses to unauthenticated
  requests in `Passport.Plugs.require_authentication`

### Fixed

- Passport.Plugs.require_authentication now actually sends the redirect or 401
  response.


## 0.1.0  (2016-04-17)

### Added

- Ability to hash and verify passwords using PBKDF2 over a SHA512 HMAC
- Ability to verify credentials against data stored in a database
- Ability to use Plug sessions to track authenticated users
- A Plug that requires an authenticated user
