defmodule Library.Test do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tests" do
    field :string, :string
    field :data, :map  # New field for the map
    timestamps(type: :utc_datetime)
  end

  def changeset(test, attrs) do
    test
    |> cast(attrs, [:string, :data])  # Include the new field
    |> validate_required([:string, :data])
  end
end
