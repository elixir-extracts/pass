defmodule Passport.DataStore do
  @moduledoc """
  A wrapper for concrete implementations of the abstract data storage functions
  used by Passport. Modules wishing to be adapters must implement the following
  functions:

  - get_by_identity/1

      Takes in the identity value to lookup in the data store and returns a map
      of the corresponding ID and hashed password string if it finds a matching
      identity, otherwise it returns nil.

  - get/1

      Retrieves the user information from the data store based on the specified
      id. If no user information is found, then return nil.
  """

  @config Application.get_env(:passport, __MODULE__, %{})
  @adapter @config[:adapter] || Passport.DataStore.EctoAdapter

  @doc """
  A wrapper function that should return the module that has the concrete
  implementations of the abstract data storage functions.
  """
	def adapter, do: @adapter
end
