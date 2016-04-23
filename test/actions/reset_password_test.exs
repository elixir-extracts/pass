defmodule Passport.ResetPasswordTest do
  use ExUnit.Case, async: false
  alias Passport.ResetPassword
  alias Passport.Test.Repo
  alias Passport.Test.User

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Repo, [])
    end

    user = Repo.insert! %User{
      username: "ft",
      email: "frank@thomases.com",
      password: Passport.Hash.db_password("MyPassword1234")
    }
    {:ok, %{user: user}}
  end

  test "generate_token/1 returns a valid JWT", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(
      ResetPassword.generate_token(user.email),
      %{key: ResetPassword.key}
    )

    assert claims[:sub] == user.email
    assert claims[:aud] == "Passport.ResetPassword"
    assert claims[:jti] != nil
    assert :os.system_time(:seconds) - claims[:iat] < 4
  end

  test "generate_token/1 stores the single-use token in the users table", %{user: user} do
    assert Repo.get!(User, user.id).passwordResetToken == nil

    {:ok, %{jti: jti}} = JsonWebToken.verify(
      ResetPassword.generate_token(user.email),
      %{key: ResetPassword.key}
    )

    assert Repo.get!(User, user.id).passwordResetToken == jti
  end


  test "verify_token/1 when JWT is invalid fails", %{user: user} do
    bad_token = ResetPassword.generate_token(user.email)
    |> String.slice(0..-4)

    assert ResetPassword.verify_token(bad_token) == {:error, "Invalid JWT"}
  end

  test "verify_token/1 when JWT has a jti token that doesn't match the stored data it fails", %{user: user} do
    bad_token = ResetPassword.generate_token(user.email)
    Repo.update!(User.changeset(user, %{passwordResetToken: "a"}))

    assert ResetPassword.verify_token(bad_token) == {:error, "Invalid password reset token"}
  end

  test "verify_token/1 when JWT has an email that doesn't match the stored data it fails", %{user: user} do
    bad_email = ResetPassword.generate_token(user.email)
    Repo.update!(User.changeset(user, %{email: "a"}))

    assert ResetPassword.verify_token(bad_email) == {:error, "Invalid password reset token"}
  end

  test "verify_token/1 when JWT has expired fails", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(ResetPassword.generate_token(user.email), %{key: ResetPassword.key})
    claims        = %{claims|iat: 1}
    bad_token     = JsonWebToken.sign(claims, %{key: ResetPassword.key})

    assert ResetPassword.verify_token(bad_token) == {:error, "Password reset time period expired"}
  end

  test "verify_token/1 when everything checks out returns :ok", %{user: user} do
    token         = ResetPassword.generate_token(user.email)
    {:ok, claims} = JsonWebToken.verify(token, %{key: ResetPassword.key})

    assert ResetPassword.verify_token(token) == {:ok, claims}
  end


  test "redeem_token/2 when JWT is invalid fails", %{user: user} do
    bad_token = ResetPassword.generate_token(user.email)
    |> String.slice(0..-4)

    assert ResetPassword.redeem_token(bad_token, "foo_bar-baz3") == {:error, "Invalid JWT"}
  end

  test "redeem_token/2 when JWT has a jti token that doesn't match the stored data it fails", %{user: user} do
    bad_token = ResetPassword.generate_token(user.email)
    Repo.update!(User.changeset(user, %{passwordResetToken: "a"}))

    assert ResetPassword.redeem_token(bad_token, "nepasswordforyou") == {:error, "Invalid password reset token"}
  end

  test "redeem_token/2 when JWT has an email that doesn't match the stored data it fails", %{user: user} do
    bad_email = ResetPassword.generate_token(user.email)
    Repo.update!(User.changeset(user, %{email: "a"}))

    assert ResetPassword.redeem_token(bad_email, "nepasswordforyou") == {:error, "Invalid password reset token"}
  end

  test "redeem_token/2 when JWT has expired fails", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(ResetPassword.generate_token(user.email), %{key: ResetPassword.key})
    claims        = %{claims|iat: 1}
    bad_token     = JsonWebToken.sign(claims, %{key: ResetPassword.key})

    assert ResetPassword.redeem_token(bad_token, "faoin3oksjslsk") == {:error, "Password reset time period expired"}
  end

  test "redeem_token/2 when JWT is valid it returns :ok", %{user: user} do
    assert ResetPassword.redeem_token(ResetPassword.generate_token(user.email), "my_new-passw0rd") == :ok
  end

  test "redeem_token/2 when JWT is valid it updates a users password", %{user: user} do
    ResetPassword.redeem_token(ResetPassword.generate_token(user.email), "my_new-passw0rd")
    assert user.password != Repo.get!(User, user.id).password
  end

  test "redeem_token/2 when JWT is valid it sets the single-use token in the users table to nil", %{user: user} do
    ResetPassword.redeem_token(ResetPassword.generate_token(user.email), "my_new-passw0rd")
    assert Repo.get!(User, user.id).passwordResetToken == nil
  end
end
