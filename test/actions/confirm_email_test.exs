defmodule Pass.ConfirmEmailTest do
  use ExUnit.Case, async: false
  alias Pass.ConfirmEmail
  alias Pass.Test.Repo
  alias Pass.Test.User

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Repo, [])
    end

    user = Repo.insert! %User{
      username: "ft",
      email: "frank@thomases.com",
      password: Pass.Hash.db_password("MyPassword1234")
    }
    {:ok, %{user: user}}
  end

  test "generate_token/1 returns a valid JWT", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(
      ConfirmEmail.generate_token(user.email),
      %{key: ConfirmEmail.key}
    )

    assert claims[:sub] == user.email
    assert claims[:aud] == "Pass.ConfirmEmail"
    assert claims[:exp] > :os.system_time(:seconds)
  end


  test "verify_token/1 when JWT is invalid fails", %{user: user} do
    bad_token = ConfirmEmail.generate_token(user.email)
    |> String.slice(0..-4)

    assert ConfirmEmail.verify_token(bad_token) == {:error, "Invalid JWT"}
  end

  test "verify_token/1 when JWT has an email that doesn't match the stored data it fails", %{user: user} do
    bad_email = ConfirmEmail.generate_token(user.email)
    Repo.update!(User.changeset(user, %{email: "a"}))

    assert ConfirmEmail.verify_token(bad_email) == {:error, "Invalid email"}
  end

  test "verify_token/1 when JWT has expired fails", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(ConfirmEmail.generate_token(user.email), %{key: ConfirmEmail.key})
    claims        = %{claims|exp: 1}
    bad_token     = JsonWebToken.sign(claims, %{key: ConfirmEmail.key})

    assert ConfirmEmail.verify_token(bad_token) == {:error, "Email confirmation time period expired"}
  end

  test "verify_token/1 when everything checks out returns :ok", %{user: user} do
    token         = ConfirmEmail.generate_token(user.email)
    {:ok, claims} = JsonWebToken.verify(token, %{key: ConfirmEmail.key})

    assert ConfirmEmail.verify_token(token) == {:ok, claims}
  end


  test "redeem_token/1 when JWT is invalid fails", %{user: user} do
    bad_token = ConfirmEmail.generate_token(user.email)
    |> String.slice(0..-4)

    assert ConfirmEmail.redeem_token(bad_token) == {:error, "Invalid JWT"}
  end

  test "redeem_token/1 when JWT has an email that doesn't match the stored data it fails", %{user: user} do
    bad_email = ConfirmEmail.generate_token(user.email)
    Repo.update!(User.changeset(user, %{email: "a"}))

    assert ConfirmEmail.redeem_token(bad_email) == {:error, "Invalid email"}
  end

  test "redeem_token/1 when JWT has expired fails", %{user: user} do
    {:ok, claims} = JsonWebToken.verify(ConfirmEmail.generate_token(user.email), %{key: ConfirmEmail.key})
    claims        = %{claims|exp: 1}
    bad_token     = JsonWebToken.sign(claims, %{key: ConfirmEmail.key})

    assert ConfirmEmail.redeem_token(bad_token) == {:error, "Email confirmation time period expired"}
  end

  test "redeem_token/1 when JWT is valid it returns :ok", %{user: user} do
    assert ConfirmEmail.redeem_token(ConfirmEmail.generate_token(user.email)) == :ok
  end

  test "redeem_token/1 when JWT is valid it sets a users email confirmation field to true", %{user: user} do
    assert not user.emailConfirmed
    ConfirmEmail.redeem_token(ConfirmEmail.generate_token(user.email))
    assert Repo.get!(User, user.id).emailConfirmed
  end
end
