defmodule Library.Test do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tests" do
    field :string, :string
    # New field for the map
    field :data, :map
    timestamps(type: :utc_datetime)
  end

  def changeset(test, attrs) do
    test
    # Include the new field
    |> cast(attrs, [:string, :data])
    |> validate_required([:string, :data])
  end
end
