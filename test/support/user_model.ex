defmodule Pass.Test.User do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string
    field :email, :string
    field :emailConfirmed, :boolean, default: false
    field :passwordResetToken, :string
  end

  @required_fields ~w(username email)
  @optional_fields ~w(password emailConfirmed passwordResetToken)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:username)
    |> validate_length(:password,  min: 8)
    |> hash_password
  end

  defp hash_password(changeset) do
    if (password = get_change(changeset, :password)) do
      changeset |> put_change(:password, Pass.Hash.db_password(password))
    else
      changeset |> delete_change(:password)
    end
  end
end
