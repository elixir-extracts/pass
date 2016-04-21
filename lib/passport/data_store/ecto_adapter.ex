defmodule Passport.DataStore.EctoAdapter do
  @moduledoc """
  Implements the abstract data storage methods that Passport relies on for the
  Ecto library.
  """

  @config Application.get_env(:passport, __MODULE__, %{})
  @repo   @config[:repo]
  @schema @config[:schema]

  @id_field       @config[:id_field]       || :id
  @identity_field @config[:identity_field] || :username
  @password_field @config[:password_field] || :password

  @doc """
  Returns a map of the id and password string stored in the database for the
  specified identity field (eg. username).
  """
  def get_by_identity(identity) do
    @repo.get_by(@schema, [{@identity_field, identity}])
    |> user_map_or_nil
  end

  defp user_map_or_nil(nil), do: nil
  defp user_map_or_nil(user) do
    %{id: Map.get(user, @id_field), password: Map.get(user, @password_field)}
  end
end
