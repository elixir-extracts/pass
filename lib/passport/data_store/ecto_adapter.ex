defmodule Passport.DataStore.EctoAdapter do
  @config Application.get_env(:passport, __MODULE__, %{})
  @repo   @config[:repo]
  @schema @config[:schema]

  @id_field       @config[:id_field]       || :id
  @identity_field @config[:identity_field] || :username
  @password_field @config[:password_field] || :password

	def get_by_identity(identity) do
    @repo.get_by(@schema, [{@identity_field, identity}])
    |> user_map_or_nil
  end

  defp user_map_or_nil(nil), do: nil
  defp user_map_or_nil(user) do
    %{id: Map.get(user, @id_field), password: Map.get(user, @password_field)}
  end
end
