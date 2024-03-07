defmodule Library.Repo.Migrations.AddActiveParseTable do
  use Ecto.Migration

  def change do
    create table(:active_parses) do
      add :timestamp, :naive_datetime
      add :book_id, references(:books, on_delete: :nothing)
      add :collection_id, references(:collections, on_delete: :nothing)

      timestamps()
    end
  end
end
