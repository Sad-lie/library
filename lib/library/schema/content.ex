defmodule Library.Schema.Content do
  use Ecto.Schema

  schema "contents" do
    field :chapter, :string
    field :parse, :integer
    field :paragraph, :string
    field :timestamp, :naive_datetime
    #belongs_to :book, Library.Books

    timestamps()
  end

  @required_fields ~w(chapter parse paragraph timestamp book_id)a
  @optional_fields ~w()a

  def changeset(contents, attrs) do
    contents
    |> Ecto.Changeset.cast(attrs, @required_fields, @optional_fields)
  end
end
