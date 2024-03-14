defmodule Library.Repo.Migrations.LibraryConnection do
  use Ecto.Migration

  def change do
    alter table(:libraries) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
