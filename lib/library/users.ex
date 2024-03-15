defmodule Library.Users do
  alias Library.Repo
  alias Library.Schema.User
  import Ecto.Query, warn: false

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
  #with telegram id
  def user_exists_by_telegram_id?(telegram_id) do
    query = from(u in User,
                 where: u.telegram_id == ^telegram_id,
                 select: u.id)

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end
  # Delete a user
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
