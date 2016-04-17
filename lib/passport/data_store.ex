defmodule Passport.DataStore do
  @config Application.get_env(:passport, __MODULE__, %{})
  @adapter @config[:adapter] || Passport.DataStore.EctoAdapter

	def adapter, do: @adapter
end
