defmodule Library.Repo.Migrations.AlterUserIdInUserTwo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :telegram_id, :string
    end
  end
end
