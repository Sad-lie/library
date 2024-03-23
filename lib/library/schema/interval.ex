defmodule Library.Schema.Interval do
  use Ecto.Schema

  import Ecto.Changeset

  schema "intervals" do
    field :interval, :integer

    timestamps()
  end

  def changeset(contents, attrs) do
    contents
    |> cast(attrs, [:interval])
    |> validate_required([:interval])
  end
end
