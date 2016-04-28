defmodule Pass.DataStore.EctoAdapter do
  @moduledoc """
  Implements the abstract data storage methods that Pass relies on for the
  Ecto library.
  """

  defp config, do: Application.get_env(:pass, __MODULE__, %{})
  defp repo,   do: config[:repo]
  defp schema, do: config[:schema]

  defp id_field,                   do: config[:id_field]                   || :id
  defp identity_field,             do: config[:identity_field]             || :username
  defp password_field,             do: config[:password_field]             || :password
  defp email_field,                do: config[:email_field]                || :email
  defp password_reset_token_field, do: config[:password_reset_token_field] || :password_reset_token
  defp email_confirmed_field,      do: config[:email_confirmed_field]      || :email_confirmed

  @doc """
  Returns a map of the id and password string stored in the database for the
  specified identity field (eg. username).
  """
  def get_by_identity(identity) do
    repo.get_by(schema, [{identity_field, identity}])
    |> user_map_or_nil
  end

  @doc """
  Returns the user with the specified ID or nil if the user can't be found.
  """
  def get(id) do
    repo.get(schema, id)
  end

  @doc """
  Stashes the password reset token so we can prevent replay attacks
  """
  def set_password_reset_token(email, token) do
    user      = user_by_email(email)
    changeset = schema.changeset(user, %{password_reset_token_field => token})
    repo.update!(changeset)
  end

  @doc """
  Returns true if a user with the specified email address and password reset
  token can be found. Otherwise it returns false.
  """
  def vaild_password_reset_token?(email, token) do
    Map.get(
      user_by_email(email) || %{},
      password_reset_token_field
    ) == token
  end

  @doc """
  Updates the password with the specified value and clears out the password
  reset token.
  """
  def update_password_for(email, password) do
    changeset = schema.changeset(
      user_by_email(email),
      %{password_field => password, password_reset_token_field => nil}
    )
    repo.update!(changeset)
  end

  @doc """
  Returns true if the email address referenes a user in the data store,
  otherwise it returns false
  """
  def valid_email?(email) do
    user_by_email(email) != nil
  end

  @doc """
  Sets the email confirmed field to true for the user with the specfied email.
  """
  def confirm_email(email) do
    changeset = schema.changeset(
      user_by_email(email),
      %{email_confirmed_field => true}
    )
    repo.update!(changeset)
  end


  defp user_by_email(email) do
    repo.get_by(schema, [{email_field, email}])
  end

  defp user_map_or_nil(nil), do: nil
  defp user_map_or_nil(user) do
    %{id: Map.get(user, id_field), password: Map.get(user, password_field)}
  end
end
