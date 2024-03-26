defmodule Library.Intervals do
  alias Library.Schema.Interval
  alias Library.Repo

  def get_interval(id) do
    Repo.get(Interval, id)
  end

  def list_intervals do
    Repo.all(Interval)
  end

  def create_interval(attrs) do
    %Interval{}
    |> Interval.changeset(attrs)
    |> Repo.insert()
  end

  def update_or_create_interval(attrs) do
    case Map.get(attrs, "id") do
      nil ->
        create_interval(attrs)

      id ->
        case get_interval(id) do
          %Interval{} = interval ->
            update_interval(interval, attrs)

          nil ->
            create_interval(attrs)
        end
    end
  end

  def update_interval(interval, attrs) do
    interval
    |> Interval.changeset(attrs)
    |> Repo.update()
  end
end
