defmodule Library.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :timestamp, :naive_datetime
    has_one :library , Library.Schema.Library
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :timestamp])
    |> validate_required([:name, :timestamp])
  end
end
