defmodule Library.Schema.Collection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "libraries" do
    field :timestamp, :naive_datetime
    belongs_to :user , Library.Schema.User
    has_many :book , Library.Schema.Book

    timestamps()
  end

  @doc false
  def changeset(collections, attrs) do
    collections
    |> cast(attrs, [:timestamp])
    |> validate_required([:timestamp])
  end
end
