defmodule Models.UserTest do
  use ExUnit.Case, async: false

  alias Passport.Test.User

  @valid_attrs %{email: "email", username: "uname", password: "some content", emailConfirmed: true, passwordResetToken: "pw token"}
  @invalid_attrs %{}

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Passport.Test.Repo, [])
    end
  end

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
