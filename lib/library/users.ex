defmodule Library.Users do
  alias Library.Repo
  alias Library.Schema.User
  alias Library.Schema.Collection
  alias Library.Schema.Book

  import Ecto.Query, warn: false
  alias Logger

  # List all users
  def list_users do
    Repo.all(User)
  end

  # Get a single user
  def get_user!(id) do
    Repo.get!(User, id)
  end

  # Create a user
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Update a user
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
  def get_user_telegram_id_by_name(name) do
    User
    |> Repo.get_by(name: name)
    |> case do
      nil ->
        {:error, :not_found}
      user ->
        {:ok, user.telegram_id}
    end
  end
  def user_exists_by_telegram_id?(telegram_id) when is_integer(telegram_id) do
    query = from(u in User, where: u.telegram_id == ^telegram_id)
    Repo.one(query) != nil
  end
  # with telegram id
  def user_exists_by_telegram_id?(telegram_id) do
    IO.inspect("Querying for telegram_id: #{telegram_id} of type #{is_integer(telegram_id)}")

    query =
      from(u in User,
        where: u.telegram_id == ^telegram_id,
        select: u.id
      )

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end

  # Delete a user
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def get_user_books(user_id) do
    Repo.all(
      from b in Book,
      join: c in assoc(b, :collection),
      join: u in assoc(c, :user),
      where: u.id == ^user_id,
      select: b
    )
  end
end
