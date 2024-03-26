defmodule Library.Schema.Book do
  use Ecto.Schema
  import Ecto.Changeset
  #alias Library.Schema.User
  alias Library.Repo
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
    |> validate_required([:name, :user_id])
    |> validate_user_exists()
    # Remove the foreign key constraint here

   # |> foreign_key_constraint(:user_id, name: "books_user_id_fkey", message: "User does not exist")
  end
  defp validate_user_exists(changeset) do
    case changeset.changes[:user_id] do
      nil -> changeset
      user_id ->
        case Repo.get(Library.Schema.User, user_id) do
          nil -> add_error(changeset, :user_id, "User with ID #{user_id} does not exist")
          _ -> changeset
        end
    end
  end
end
