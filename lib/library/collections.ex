defmodule Library.Collections do
  alias Library.Repo
  alias Library.Schema.Collection
  import Ecto.Query, warn: false

  # List all collections
  def list_collections do
    Repo.all(Collection)
  end

  # Get a single collection
  def get_collection!(id) do
    Repo.get!(Collection, id)
  end

  # Create a collection
  def create_collection(attrs) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end
  #add book to user


  # Update a collection
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  # Delete a collection
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end
end
