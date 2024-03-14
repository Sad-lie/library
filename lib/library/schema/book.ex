defmodule Library.Schema.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :name, :string
    field :timestamp, :naive_datetime
    field :data, :map
    belongs_to :library , Library.Schema.Library
    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :timestamp, :data])
    |> validate_required([:name, :timestamp])
  end
end
