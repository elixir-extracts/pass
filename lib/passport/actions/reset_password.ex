defmodule Passport.ResetPassword do
  @moduledoc """
  Handles password resets by generating, verifying, and redeeming JWTs.

  The idea is that you would use `Passport.ResetPassword.generate_token/1` to
  create a JWT that you could then send to the user (probably in a link in an
  email).

  When the user accesses your interface redeem the token and reset their
  password, you would use `Passport.ResetPassword.verify_token/2` to first
  verify the JWT and that the time has not expired before asking for the new
  password.

  Once the user has given you the new password, you would use
  `Passport.ResetPassword.redeem_token/2` which would first verify the JWT and
  then reset the password.

  To prevent replay attacks, we generate a random string to send in the jti
  attribute of the JWT and store it in the data store.
  """

  @config Application.get_env(:passport, __MODULE__, %{})
  @timeout @config[:timeout] || 60 * 60 * 2

  @doc """
  Returns the secret key used to sign the JWT.
  """
  def key, do: @config[:key]

  @doc """
  Takes in an email address and creates a JWT with the following claims:
    - sub: The email address passed in
    - aud: "Passport.ResetPassword"
    - jti: Random 16 bytes encoded as URL-safe base 64 string with no padding
    - iat: The current time from epoch in seconds
  """
  def generate_token(email) do
    jti = Base.url_encode64(:crypto.strong_rand_bytes(16), padding: false)
    Passport.DataStore.adapter.set_password_reset_token(email, jti)

    %{
      sub: email,
      aud: "Passport.ResetPassword",
      jti: jti,
      iat: :os.system_time(:seconds)
    } |> JsonWebToken.sign(%{key: key})
  end

  @doc """
  Takes in a JWT to verify and the new password that will be set for the user if
  the JWT is valid and hasn't expired.
  """
  def redeem_token(token, password) do
    case verify_token(token) do
      {:ok, claims} ->
        Passport.DataStore.adapter.update_password_for(claims.sub, password)
        :ok
      error ->
        error
    end
  end

  @doc """
  Takes in a password reset JWT and verifies that the JWT is valid, that the JWT
  hasn't expired, and that the email address in the sub attribute and the random
  string in the jti attribute match a user in the data store.
  """
  def verify_token(token) do
    case JsonWebToken.verify(token, %{key: key}) do
      {:error, _} ->
        {:error, "Invalid JWT"}

      {:ok, claims} ->
        cond do
          :os.system_time(:seconds) - claims.iat > @timeout ->
            {:error, "Password reset time period expired"}
          not Passport.DataStore.adapter.vaild_password_reset_token?(claims.sub, claims.jti) ->
            {:error, "Invalid password reset token"}
          true ->
            {:ok, claims}
        end
    end
  end
end
