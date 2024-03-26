defmodule Library.Schema.Book do
  use Ecto.Schema
  import Ecto.Changeset
  #alias Library.Schema.User
  alias Library.Repo
  schema "books" do
    field :name, :string
    field :book_id, :integer
    field :telegram_id, :string
    field :timestamp, :naive_datetime
    has_many :content, Library.Schema.Content
    belongs_to :collection, Library.Schema.Collection

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :telegram_id])
    |> validate_required([:name, :telegram_id])
    |> validate_user_exists()
    # Remove the foreign key constraint here

   # |> foreign_key_constraint(:user_id, name: "books_user_id_fkey", message: "User does not exist")
  end
  defp validate_user_exists(changeset) do
    case changeset.changes[:telegram_id] do
      nil -> changeset
      telegram_id ->
        case Repo.get(Library.Schema.User, telegram_id) do
          nil -> add_error(changeset, :telegram_id, "User with ID #{telegram_id} does not exist")
          _ -> changeset
        end
    end
  end

end
# book_data = %{
#   name: "Elixir intro",
#   telegram_id: "977_236_716",
#   timestamp: ~N[2024-03-25 10:27:54]
# }
