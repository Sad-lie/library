defmodule Library.Repo.Migrations.AlterUserIdInBookTwo do
  use Ecto.Migration

  def change do
    alter table(:books) do
      modify :telegram_id, :string
    end
  end
end
