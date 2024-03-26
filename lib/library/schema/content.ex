defmodule Library.Schema.Content do
  use Ecto.Schema

  import Ecto.Changeset

  schema "contents" do
    field :chapter, :string
    field :timestamp, :naive_datetime
    field :data, :map
    field :telegram_id, :string
    # Uncomment and adjust if you still have a book association
    belongs_to :book, Library.Schema.Book

    timestamps()
  end

  def changeset(contents, attrs) do
    contents
    |> cast(attrs, [:chapter, :timestamp, :data, :book_id])
    |> validate_required([:chapter, :timestamp])
  end
end



# Erlang/OTP 26 [erts-14.1.1] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit:ns]

# # Interactive Elixir (1.15.7) - press Ctrl+C to exit (type h() ENTER for help)
# %{
#   "callback_query" => %{"data" => data,"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name"username" => username}},"date" => 1711290633,"text" => text }}}
# "/interval 5"
# ["/interval", "5"]
# %{
#   "callback_query" => %{
#     "data" => data,
#     "message" => %{
#       "chat" => %{
#         "first_name" => first_name,
#         "id" => chat_id,
#         "last_name" => last_name,
#         "username" => username
#       }
#     },
#     "date" => 1711290633,
#     "text" => text
#   }
# }
# %{"callback_query" => %{"data" => data,"message" => %{
#       "chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name"username" => username}},"text" => "Here are the list of Chapters, please select one:"}}}
# "toc"
# ["toc"]
# [debug] QUERY OK source="books" db=1.0ms queue=1.5ms idle=37.3ms
# SELECT b0."id", b0."name", b0."book_id", b0."user_id", b0."timestamp", b0."collection_id", b0."inserted_at", b0."updated_at" FROM "books" AS b0 WHERE (b0."user_id" = $1) [977236716]
# ↳ Library.TelegramPoller.process_list/3, at: lib/library/telegram_poller.ex:241
# []
# iex(1)>
