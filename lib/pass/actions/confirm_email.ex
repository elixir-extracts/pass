defmodule Pass.ConfirmEmail do
  @moduledoc """
  Handles email confirmations by generating, verifying, and redeeming JWTs.

  The idea is that you would use `Pass.ConfirmEmail.generate_token/1` to
  create a JWT that you could then send to the user (probably emailing them a
  link.

  When the user accesses your interface to confirm their email, you would use
  `Pass.ConfirmEmail.redeem_token/1` which would first verify the JWT and
  then set the email confirmed field to true.

  There's no need to prevent replay attacks since all we are doing is setting a
  field to "true". The token could be used multiple times without without an
  issue, the results would always be the same.
  """

  defp config,  do: Application.get_env(:pass, __MODULE__, %{})
  defp timeout, do: config[:timeout] || 60 * 60 * 48

  @doc """
  Returns the secret key used to sign the JWT.
  """
  def key, do: config[:key]

  @doc """
  Takes in an email address and creates a JWT with the following claims:
    - sub: The email address passed in
    - aud: "Pass.ConfirmEmail"
    - exp: The time from epoch in seconds when the token expires
  """
  def generate_token(email) do
    %{
      sub: email,
      aud: "Pass.ConfirmEmail",
      exp: :os.system_time(:seconds) + timeout
    } |> JsonWebToken.sign(%{key: key})
  end

  @doc """
  Sets the email confirmed field to true if the JWT is valid, otherwise it
  returns the error.
  """
  def redeem_token(token) do
    case verify_token(token) do
      {:ok, claims} ->
        Pass.DataStore.adapter.confirm_email(claims.sub)
        :ok
      error ->
        error
    end
  end

  @doc """
  Takes in an email confirmation JWT and verifies that the JWT is valid, that
  it hasn't expired, and that the email address in the sub attribute match a
  user in the data store.
  """
  def verify_token(token) do
    case JsonWebToken.verify(token, %{key: key}) do
      {:error, _} ->
        {:error, "Invalid JWT"}

      {:ok, claims} ->
        cond do
          claims.exp < :os.system_time(:seconds) ->
            {:error, "Email confirmation time period expired"}
          not Pass.DataStore.adapter.valid_email?(claims.sub) ->
            {:error, "Invalid email"}
          true ->
            {:ok, claims}
        end
    end
  end
end
