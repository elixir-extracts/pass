defmodule Pass.DataStore do
  @moduledoc """
  A wrapper for concrete implementations of the abstract data storage functions
  used by Pass. Modules wishing to be adapters must implement the following
  functions:

  - confirm_email/1

      Takes in an email address and sets the email confirmed field to true for
      the user with the specfied email.

  - get/1

      Retrieves the user information from the data store based on the specified
      id. If no user information is found, then return nil.

  - get_by_identity/1

      Takes in the identity value to lookup in the data store and returns a map
      of the corresponding ID and hashed password string if it finds a matching
      identity, otherwise it returns nil.

  - set_password_reset_token/2

      Takes in the email and the random string that will be in the jti attribute
      of the JWT and stores that value in the password reset token field.

  - update_password_for/2
      Takes in an email address and a new password. It then updates the password
      of the user with that email address and clears the password reset token
      attribute.

  - valid_email?/1

      Takes in a value and returns true if that value exists as an email for a
      user in the data store, otherwise it returns false.

  - valid_password_reset_token?/2

      Takes in the email and the random string from the jti attribute of the JWT
      and returns true if a matching user can be found in the data store,
      otherwise it returns false.
  """

  @config Application.get_env(:pass, __MODULE__, %{})
  @adapter @config[:adapter] || Pass.DataStore.EctoAdapter

  @doc """
  A wrapper function that should return the module that has the concrete
  implementations of the abstract data storage functions.
  """
	def adapter, do: @adapter
end
