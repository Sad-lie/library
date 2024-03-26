defmodule Library.Repo.Migrations.AlterUsersTelegramIdType do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :telegram_id, :decimal
    end
  end
end
