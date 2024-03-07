defmodule Library.Repo.Migrations.AddContentTable do
  use Ecto.Migration

  def change do
    create table(:contents) do
      add :chapter, :text
      add :parse, :integer
      add :paragraph, :text
      add :timestamp, :naive_datetime
      add :book_id, references(:books, on_delete: :delete_all)

      timestamps()
    end
  end
end
