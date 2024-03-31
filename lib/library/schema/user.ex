defmodule Library.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :telegram_id, :string
    field :first_name, :string
    field :last_name, :string
    field :timestamp, :naive_datetime
    has_one :collection, Library.Schema.Collection
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :telegram_id, :first_name, :last_name, :timestamp])
    |> validate_required([:name, :telegram_id, :timestamp])
    # |> put_change(:name, get_change(user, :name))
    # |> put_change(:telegram_id, get_change(user, :telegram_id))
    # |> put_change(:timestamp, get_change(user, :timestamp, NaiveDateTime.utc_now()))
  end

end
