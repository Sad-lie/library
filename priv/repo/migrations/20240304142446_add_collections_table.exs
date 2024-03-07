defmodule Library.Repo.Migrations.AddCollectionsTable do
  use Ecto.Migration

  def change do
    create table(:collections) do
      add :timestamp, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
