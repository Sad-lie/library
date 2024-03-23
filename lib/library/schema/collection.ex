# defmodule Library.Schema.Collection do
#   use Ecto.Schema
#   import Ecto.Changeset
#   alias Library.Schema.User
#   # schema "libraries" do
#   schema "collections" do
#     field :timestamp, :naive_datetime
#     belongs_to :user, Library.Schema.User
#     has_many :book, Library.Schema.Book

#     timestamps()
#   end

#  @doc false
#  def changeset(collection, attrs) do
#   collection
#   |> Library.Schema.Collection.changeset(attrs)
#   |> put_assoc(:user, Library.Schema.User.changeset(%Library.Schema.User{}, %{name: attrs[:name], telegram_id: attrs[:telegram_id]}))
# end
# end
defmodule Library.Schema.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Schema.User

  schema "collections" do
    field :timestamp, :naive_datetime
    belongs_to :user, Library.Schema.User
    has_many :books, Library.Schema.Book

    timestamps()
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    # Assuming :user_id is the foreign key for user
    |> cast(attrs, [:timestamp, :user_id])
    |> validate_required([:timestamp, :user_id])
    |> put_assoc(
      :user,
      Library.Schema.User.changeset(User, %{name: attrs[:name], telegram_id: attrs[:telegram_id]})
    )
  end
end
