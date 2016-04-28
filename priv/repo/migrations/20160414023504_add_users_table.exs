defmodule Pass.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :password, :text, null: false
      add :email, :text, null: false
      add :emailConfirmed, :boolean, default: false
      add :passwordResetToken, :text
    end
    create index(:users, [:username], unique: true)
    create index(:users, [:email], unique: true)
  end
end
