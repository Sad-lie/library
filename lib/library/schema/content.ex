defmodule Library.Schema.Content do
  use Ecto.Schema

  import Ecto.Changeset

  schema "contents" do
    field :chapter, :string
    field :timestamp, :naive_datetime
    field :data, :map
    # Uncomment and adjust if you still have a book association
    belongs_to :book, Library.Schema.Book

    timestamps()
  end

  def changeset(contents, attrs) do
    contents
    |> cast(attrs, [:chapter, :timestamp, :data, :book_id])
    |> validate_required([:chapter, :timestamp])
  end
end
