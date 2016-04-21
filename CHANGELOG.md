# Change Log

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
