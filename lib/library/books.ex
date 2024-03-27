defmodule Library.Books do
  alias Library.Repo
  alias Library.Schema.Book
  import Ecto.Query, warn: false
  require Logger
  # List all
  def list_books do
    Repo.all(Book)
  end
  def list_book(chat_id) do
    IO.inspect(chat_id)
    new_chat_id = to_string(chat_id)
    IO.inspect(new_chat_id)
    query = from(r in Book, where: r.telegram_id == ^new_chat_id, select: r.id)
    Repo.exists?(query)
  end

  def get_book_by_name(file_name) do
    IO.inspect(file_name)
    query = from(r in Book, where: r.name == ^file_name, select: r.name)
    Repo.exists?(query)
  end
  def get_book_id(file) do
    file_name = to_string(file)
    query = from(r in Book, where: r.name == ^file_name, select: r.book_id)
    Repo.all(query)
  end
  # Get a single
  @spec get_book!(any()) :: any()
  def get_book!(id) do
    Repo.get!(Book, id)
  end

  # Create a book
  def create_book(attrs) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  # Update a book
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  # Delete a book
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  # deelete all
  def delete_all(schema_module) do
    # Create a query that selects all records from the given schema
    query = from(s in schema_module, select: s)

    # Execute the delete operation
    Repo.delete_all(query)
  end
  def get_books_by_user_id(user_id) do
    # Query the database or data source to retrieve books for the given user_id
    # Example: Assuming there is a Book schema and a User-Book association
    books = Book
            |> where([b], b.user_id == ^user_id)
            |> Repo.all()

    # Return the list of books
    books
  end
  # def get_books_by_user_id(user_id) do
  #   from(b in Book,
  #     where: b.user_id == ^user_id,
  #     select: b
  #   )
  #   |> Repo.all()
  # end

  def add_book_to_user_collection(user_id, book_attrs) do
    user = Library.Users.get_user!(user_id)

    # First, build the association without a changeset
    book = Ecto.build_assoc(user, :books, book_attrs)

    # Then, create a changeset for the new book
    changeset = Book.changeset(book, book_attrs)

    # Finally, insert the new book into the database
    Repo.insert(changeset)
  end

  # list books data
  def list_data do
    Repo.all(Book)
  end

  # list users books
  def list_user_books(user_id) do
    user = Library.Users.get_user!(user_id)
    Repo.all(from b in Book, where: b.user_id == ^user.id)
  end
end





# add book to collection
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
