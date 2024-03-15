defmodule Library.Repo.Migrations.AddTelegramIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :telegram_id , :integer
    end
  end
end
