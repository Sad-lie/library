defmodule Library.Repo.Migrations.IntervalTable do
  use Ecto.Migration

  def change do
    create table(:intervals) do
      add :interval, :integer
      add :timestamp, :naive_datetime

      timestamps()
    end
  end
end
