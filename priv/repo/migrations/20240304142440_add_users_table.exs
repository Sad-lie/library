defmodule Library.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :timestamp, :naive_datetime

      timestamps()
    end
  end
end
