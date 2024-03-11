defmodule Library.Repo do
  use Ecto.Repo,
    otp_app: :library,
    adapter: Ecto.Adapters.Postgres,
    schema_prefix: "schemas"
end
