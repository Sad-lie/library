defmodule Library.Repo.Migrations.MapData do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :data, :jsonb
    end
  end
end
