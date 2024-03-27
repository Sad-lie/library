defmodule Library.Repo.Migrations.ChangeContentBook do
  use Ecto.Migration

  def change do
    alter table(:contents) do
      modify :book_id, :integer
    end
  end
end
