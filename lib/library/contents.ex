defmodule Library.Contents do
  alias Library.Repo
  alias Library.Schema.Content
  import Ecto.Query, warn: false
  require Logger
  # List all
  def list_contents do
    Repo.all(Content)
  end

  # Get a single
  def get_content!(id) do
    Repo.get!(Content, id)
  end

  # Create a Content
  def create_content(attrs) do
    %Content{}
    |> Content.changeset(attrs)
    |> Repo.insert()
  end

  # Update a content
  def update_content(%Content{} = content, attrs) do
    content
    |> Content.changeset(attrs)
    |> Repo.update()
  end

  # Delete a content
  def delete_content(%Content{} = content) do
    Repo.delete(content)
  end

  # deelete all
  def delete_all(schema_module) do
    # Create a query that selects all records from the given schema
    query = from(s in schema_module, select: s)

    # Execute the delete operation
    Repo.delete_all(query)
  end

  def add_content_to_user_collection(user_id, content_attrs) do
    user = Library.Users.get_user!(user_id)

    # First, build the association without a changeset
    content = Ecto.build_assoc(user, :contents, content_attrs)

    # Then, create a changeset for the new Content
    changeset = Content.changeset(content, content_attrs)

    # Finally, insert the new Content into the database
    Repo.insert(changeset)
  end

  # list Contents data
  def list_data do
    Repo.all(Content)
  end

  # list users Contents
  def list_user_content(user_id) do
    user = Library.Users.get_user!(user_id)
    Repo.all(from b in Content, where: b.user_id == ^user.id)
  end
end

# add Content to collection
# def add_book_to_user_collection(user_id, book_attrs) do
#   user = Library.Users.get_user!(user_id)
#   %Book{}
#   |> Book.changeset(book_attrs)
#   |> Ecto.build_assoc(user, :books)
#   |> Repo.insert()
# end

  # one daya book
  # def get_book_data_by_name(book_name) do
  #   # Query to find a book by its name and select only the `data` field
  #   query =
  #     from(b in Book,
  #       where: b.name == ^book_name,
  #       select: b.data
  #     )

  #   # Execute the query to fetch the `data` field of the matching book
  #   # case Repo.one(query) do
  #   #   nil -> {:error, "Book not found"}
  #   #   data_map -> {:ok, data_map}
  #   # end
  #   case Repo.one(query) do
  #     nil ->
  #       Logger.error("Book not found: #{book_name}")
  #       {:error, "Book not found"}
  #     data_map ->
  #       Logger.info("Book data retrieved successfully: #{book_name}")
  #       {:ok, data_map}
  #   end

  # enddef get_book_data_by_name(book_name) do
 # def get_book_data(book_id) do
  #   book = Repo.get(Book, book_id)
  #   book.data
  # end
