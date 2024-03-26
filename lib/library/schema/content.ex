defmodule Library.Schema.Content do
  use Ecto.Schema

  import Ecto.Changeset

  schema "contents" do
    field :chapter, :string
    field :timestamp, :naive_datetime
    field :data, :map
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

# Interactive Elixir (1.15.7) - press Ctrl+C to exit (type h() ENTER for help)
# %{
#   "callback_query" => %{
#     "chat_instance" => "6509963073383297327",
#     "data" => "/interval 5",
#     "from" => %{
#       "first_name" => "Wania",
#       "id" => 977236716,
#       "is_bot" => false,
#       "language_code" => "en",
#       "last_name" => "#",
#       "username" => "Lau_riel"
#     },
#     "id" => "4197199736698309329",
#     "message" => %{
#       "chat" => %{
#         "first_name" => "Wania",
#         "id" => 977236716,
#         "last_name" => "#",
#         "type" => "private",
#         "username" => "Lau_riel"
#       },
#       "date" => 1711290633,
#       "from" => %{
#         "first_name" => "Bookread",
#         "id" => 6572036459,
#         "is_bot" => true,
#         "username" => "deathreadbot"
#       },
#       "message_id" => 1872,
#       "reply_markup" => %{
#         "inline_keyboard" => [
#           [
#             %{"callback_data" => "/interval 5", "text" => "5 Sec"},
#             %{"callback_data" => "/interval 30", "text" => "30 Sec"},
#             %{"callback_data" => "/interval 60", "text" => "60 Sec"},
#             %{"callback_data" => "/interval 300", "text" => "5 Mins"},
#             %{"callback_data" => "/interval 1800", "text" => "30 Mins"},
#             %{"callback_data" => "/interval 3600", "text" => "60 Mins"},
#             %{"callback_data" => "/interval 7200", "text" => "2 Hrs"},
#             %{"callback_data" => "/interval 14400", "text" => "4 Hrs"}
#           ]
#         ]
#       },
#       "text" => "Select the interval:"
#     }
#   },
#   "update_id" => 231984697
# }
# "/interval 5"
# ["/interval", "5"]

# %{
#   "callback_query" => %{

#     "data" => "toc",
#     "from" => %{
#       "first_name" => first_name,
#       "id" => chat_id,
#       "last_name" => last_name
#       "username" => username
#     },
#     "message" => %{
#       "chat" => %{
#         "first_name" => first_name,
#         "id" => chat_id,
#         "last_name" => last_name

#         "username" => username
#       },
#       "date" => 1711290585,
#       "from" => %{

#       }
#       "reply_markup" => %{
#         "inline_keyboard" => [
#           [%{"callback_data" => "cover", "text" => "cover"}],
#           [%{"callback_data" => "The_Idiot", "text" => "The_Idiot"}],
#           [%{"callback_data" => "toc", "text" => "toc"}]
#         ]
#       },
#       "text" => "Here are the list of Chapters, please select one:"
#     }
#   },
#   "update_id" => 231984698
# }
# "toc"
# ["toc"]
# [debug] QUERY OK source="books" db=1.0ms queue=1.5ms idle=37.3ms
# SELECT b0."id", b0."name", b0."book_id", b0."user_id", b0."timestamp", b0."collection_id", b0."inserted_at", b0."updated_at" FROM "books" AS b0 WHERE (b0."user_id" = $1) [977236716]
# ↳ Library.TelegramPoller.process_list/3, at: lib/library/telegram_poller.ex:241
# []
# iex(1)>
