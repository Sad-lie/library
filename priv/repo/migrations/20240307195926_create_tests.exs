defmodule Library.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :string, :string
      add :text, :text
      add :number, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
