defmodule Library.Repo.Migrations.AlterUsersTelegramIdTypeAgain do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :telegram_id, :decimal, precision: 20, scale: 0
    end
  end
end
