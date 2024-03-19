defmodule Library.Repo.Migrations.UpdateBookTable do
  use Ecto.Migration

  def change do
    alter table(:books) do
      remove :data, :map
      add :book_id, :integer
    end
  end
end
