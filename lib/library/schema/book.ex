defmodule Library.Schema.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :name, :string
    field :book_id, :integer
    field :timestamp, :naive_datetime
    has_many :content, Library.Schema.Content

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :timestamp])
    |> validate_required([:name, :timestamp])
  end
end
