defmodule Library.Schema.Collection do
  use Ecto.Schema
  import Ecto.Changeset
  # schema "libraries" do
  schema "collections" do
    field :timestamp, :naive_datetime
    belongs_to :user, Library.Schema.User
    has_many :book, Library.Schema.Book

    timestamps()
  end

 @doc false
 def changeset(collection, attrs) do
  collection
  |> Library.Schema.Collection.changeset(attrs)
  |> put_assoc(:user, Library.Schema.User.changeset(%Library.Schema.User{}, %{name: attrs[:name], telegram_id: attrs[:telegram_id]}))
end
end
