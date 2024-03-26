defmodule Library.Repo.Migrations.BookConnection do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :library_id, references(:libraries, on_delete: :delete_all)
    end
  end
end
