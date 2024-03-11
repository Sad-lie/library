defmodule Library.Repo.Migrations.AddMetadataTable do
  use Ecto.Migration

  def change do
    create table(:metadata) do
      add :title, :text
      add :author, :string
      add :year, :integer
      add :chapter, :integer
      add :total_parse, :integer
      add :timestamp, :naive_datetime
      add :book_id, references(:books, on_delete: :delete_all)

      timestamps()
    end
  end
end
