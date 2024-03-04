defmodule Database do
  use Ecto.schema
  import Ecto.Changeset

  schema "user" do
    field :id ,:integer
    field :name, :string
    field :timestamp, :naive_datetime
    has_one :collection
  end

  schema "collection" do
    field :id , :integer
    field :timestamp, :naive_datetime
    belongs_to :user
    has_many :books, Book.metadata
    has_many :current_segments
  end
  schema "library" do
    field :id ,:integer
    field :timestamp, :naive_datetime
    has_many :books ,Book.metadata
  end
  schema "current_parse" do
    field :id ,:integer
    field :timestamp, :naive_datetime
    belongs_to :book ,Book.content
    belongs_to :collection
  end
  schema "book" do
    field :id ,:integer
    field :name, :string
    field :timestamp, :naive_datetime
    has_one :metadata
    has_one :content
  end
  schema "metadata" do
    field :title, :text
    field :author, :string
    field :year,:integer
    field :chapter, :integer
    field :total_parse,:integer
    field :timestamp, :naive_datetime
  end
  schema "content" do
    field :chapter, :text
    field :parse, :integer
    field :paragraph ,:text
    field :timestamp, :naive_datetime
  end
end


  # def changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:name, :timestamp])
  #   #|> validate_required([:name, :timestamp])
  # end
