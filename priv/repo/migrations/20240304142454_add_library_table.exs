defmodule Library.Repo.Migrations.AddLibraryTable do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :timestamp, :naive_datetime

      timestamps()
    end
  end
end
