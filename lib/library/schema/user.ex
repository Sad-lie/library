defmodule Library.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :telegram_id, :integer
    field :timestamp, :naive_datetime
   # has_one :collection , Library.Schema.Collection
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name,:telegram_id, :timestamp])
    |> validate_required([:name,:telegram_id, :timestamp])
  end
end
