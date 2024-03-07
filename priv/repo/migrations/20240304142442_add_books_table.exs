defmodule Library.Repo.Migrations.AddBooksTable do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :timestamp, :naive_datetime
      timestamps()
    end
  end
end
