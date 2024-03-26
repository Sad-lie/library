defmodule Library.Repo.Migrations.AlterUserIdInContentTwo do
  use Ecto.Migration

  def change do
    alter table(:contents) do
      modify :telegram_id, :string
    end
  end
end
