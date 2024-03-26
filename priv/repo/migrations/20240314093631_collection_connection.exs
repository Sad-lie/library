defmodule Library.Repo.Migrations.CollectionConnection do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :collection_id, references(:collections, on_delete: :delete_all)
    end
  end
end
