defmodule Library.Repo.Migrations.AlterUserIdInBook do
  use Ecto.Migration

  def change do
    alter table(:books) do
      remove :user_id, :integer
      add :telegram_id, :decimal, precision: 20, scale: 0
    end
  end
end
