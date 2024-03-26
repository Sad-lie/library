defmodule Library.Repo.Migrations.UpdateContentsTable do
  use Ecto.Migration

  def change do
    alter table(:contents) do
      remove :parse
      remove :paragraph
      add :data, :map
    end
  end
end
