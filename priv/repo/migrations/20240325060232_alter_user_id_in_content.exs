defmodule Library.Repo.Migrations.AlterUserIdInContent do
  use Ecto.Migration

  def change do
    alter table(:contents) do
      add :telegram_id, :decimal, precision: 20, scale: 0
    end
  end
end
