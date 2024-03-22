defmodule Library.Schema.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :name, :string
    field :book_id, :integer
    field :user_id, :integer
    field :timestamp, :naive_datetime
    has_many :content, Library.Schema.Content
    belongs_to :collection, Library.Schema.Collection

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :user_id])
    |> foreign_key_constraint(:books_user_id_fkey, message: "User does not exist")

  end

end
