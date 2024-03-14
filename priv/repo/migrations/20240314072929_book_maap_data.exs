defmodule Library.Repo.Migrations.BookMaapData do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :data, :jsonb
    end
  end
end
