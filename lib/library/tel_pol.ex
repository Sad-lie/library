# defmodule Library.TelegramPoller do
#   use GenServer
#   alias LibraryWeb.MyFile
#   alias Library.TelegramAPI
#   alias LibraryWeb.TelegramController, as: Telegram
#   alias Library.TelegramPoller.Process, as: Process
#   require Logger
#   alias HTTPoison

#   @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
#   @base_url "https://api.telegram.org/"
#   # GenServer

#   def start_link(_opts) do
#     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
#   end

#   @spec init(any()) :: {:ok, %{last_update_id: 0}}
#   def init(_state) do
#     schedule_polling()
#     {:ok, %{last_update_id: 0}}
#   end

#   @spec schedule_polling() :: reference()
#   def schedule_polling do
#     Process.send_after(self(), :poll, 5_000)
#   end

#   def handle_info(:poll, state) do
#     # Logger.info("Polling for updates...")
#     new_state = fetch_updates(state)
#     schedule_polling()
#     {:noreply, new_state}
#   end

#   def fetch_updates(%{last_update_id: last_update_id} = state) do
#     # Logger.info("Fetching updates...")
#     token = Application.get_env(:library, Library.TelegramBot)[:token]

#     case Library.TelegramAPI.get_updates(token, last_update_id) do
#       {:ok, updates} when updates != [] ->
#         Enum.each(updates, &process_update/1)

#         new_last_update_id =
#           updates
#           |> Enum.max_by(fn update -> update["update_id"] end)
#           |> Map.get("update_id")
#           |> Kernel.+(1)

#         %{state | last_update_id: new_last_update_id}

#       {:ok, _updates} ->
#         state

#       {:error, reason} ->
#         Logger.error("Failed to fetch updates: #{inspect(reason)}")
#         state
#     end
#   end

#   def start_link(_opts) do
#     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
#   end
#   # process update
#   def process_update(update) do
#     try do
#       # Your existing process_update logic
#       case update do
#         %{
#           "callback_query" => %{
#             "data" => data,
#             "message" => %{
#               "chat" => %{
#                 "first_name" => first_name,
#                 "id" => chat_id,
#                 "last_name" => last_name,
#                 "username" => username
#               }
#             },
#             "date" => 1711290633,
#             "text" => in_text
#           }
#         } ->
#             process_callback_query(data, chat_id, first_name, last_name, username,in_text)
#          %{"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name,"username" => username},"text" => text } } ->
#             process_text_message(text, chat_id, first_name, last_name, username)
#          %{
#           "message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name,"username" => username},
#           "document" => %{"file_id" => file_id,"file_name" => file_name,"mime_type" => "application/epub+zip"}}} ->
#              process_documents(first_name, last_name, username, chat_id, file_id, file_name)
#          _ ->
#           # Handle unexpected updates
#           process_error()
#       end
#     rescue
#       exception ->
#         pid = self()
#         Logger.error("Error processing update (PID: #{inspect(pid)}): #{inspect(exception)}")

#         error_response = handle_errors(exception)
#         error_message = case error_response do
#           {:error, :case_clause_error} -> "A case clause error occurred."
#           {:error, :key_missing} -> "A required key is missing."
#           {:error, :unknown_error} -> "An unexpected error occurred."
#         end

#         # You can send an error message to the user or take any other appropriate action
#         Telegram.sendMessage("An unexpected error occurred (PID: #{inspect(pid)}): #{error_message}", @chat_id)

#         # Reset the poller if
#         nil
#     end
#   end

#     def process_text_message(text, chat_id, first_name, last_name, username) do
#       case text do
#         "/chapter" -> Process.process_chapter("/chapter", chat_id)
#         "/list" -> Process.process_list("/list", chat_id,username)
#         "/interval" -> Process.process_intervel("/interval", chat_id)
#         "/start" -> Process.process_start("/start", chat_id, first_name, last_name, username)
#         _ -> Process.process_text(text, chat_id)
#       end
#     end


#   def process_callback_query(data, chat_id, first_name, last_name, username,in_text) do
#     case in_text do
#       "Here are the list of Chapters, please select one:"-> Process.process_callback_chapter("/chapter",data, chat_id)
#       "Here are the list of books, please select one:"-> Process.process_callback_list("/list", chat_id,data,username)
#       "Select the interval:"-> Process.process_callback_intervel("/interval",data, chat_id)
#       _ -> Telegram.sendMessage("Some Issue with the call back", @chat_id)
#     end
#   end



# end
# defmodule Library.TelegramPoller.Process do
#   def process_start("/start", chat_id, first_name, last_name, username) do
#     {:ok, decimal}  =  Library.Users.get_user_telegram_id_by_name(username)
#     user_id = Decimal.to_integer(decimal)
#     IO.inspect(user_id)

#     case Library.Users.user_exists_by_telegram_id?(user_id) do
#       false ->
#         current_time = DateTime.utc_now() |> DateTime.to_string()
#         collection_id = :rand.uniform(1000_000_000) |> Kernel.+(user_id)

#         user_attrs = %{
#           "telegram_id" => user_id,
#           "name" => username,
#           "first_name" => first_name,
#           "last_name" => last_name,
#           "timestamp" => current_time
#         }

#         IO.inspect(user_attrs)

#         {:ok, user} = Library.Users.create_user(user_attrs)

#         collection_attrs = %{"timestamp" => current_time, "user_id" => user.id}
#         IO.inspect(collection_attrs)

#         {:ok, collection} = Library.Collections.create_collection(collection_attrs)
#         IO.inspect(collection)

#         Telegram.sendMessage(
#           "Welcome to the Library Bot. Your account has been created, with #{first_name} #{last_name}",
#           chat_id
#         )

#       true ->
#         Telegram.sendMessage(
#           "Hey #{first_name} #{last_name} Welcome back to the Library Bot.",
#           chat_id
#         )
#     end
#   end
#   def process_list("/list", chat_id,username) do
#     {:ok, decimal}  =  Library.Users.get_user_telegram_id_by_name(username)
#     user_id = Decimal.to_integer(decimal)
#     IO.inspect(user_id)

#     books = Library.Books.get_books_by_user_id(user_id)
#     IO.inspect(books)
#     if Enum.empty?(books) do
#       Telegram.sendMessage(
#         "You haven't added any books yet. Please upload a book first.",
#         chat_id
#       )
#     else
#       list = Enum.map(books, fn book -> book["name"] end)
#       send_books_list(list, "Here are the list of books, please select one:", chat_id)
#     end
#   end

#   def process_chapter("/chapter", chat_id) do
#     list = Library.Contents.list_contents()
#     IO.inspect(list)
#     if Enum.empty?(list) do
#       Telegram.sendMessage(
#         "There are no chapters available. Please upload a book first.",
#         chat_id
#       )
#     else
#       # books_list =
#       #   Enum.map(list, fn book ->
#       #     "#{book.chapter}#{book.data["author"]}"
#       #   end)

#         list = Library.Contents.list_contents()
#         books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
#         send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
#       end
#   end

#   def process_intervel("/interval", chat_id) do
#     interval_options = ["5", "30", "60", "300", "1800", "3600", "7200", "14400"]

#     interval_labels = ["5 Sec","30 Sec","1 Mins","5 Mins","30 Mins","1 Hrs"]

#     send_interval_options(interval_options, interval_labels, "Select the interval:", chat_id)
#   end
#   #call backs

#   def handle_callback_list("/list", chat_id,data, user_id) do
#     IO.inspect(data)
#     # books = Library.Books.get_books_by_user_id(user_id)
#     # list = Enum.map(books, fn book -> book["name"] end)
#    # send_books_list(list, "Here are the list of books, please select one:", chat_id)
#   end

#   def handle_callback_chapter("/chapter", data,chat_id) do
#     IO.inspect(data)
#     # list = Library.Contents.list_contents()
#     # books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
#     # send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
#   end

#   def handle_callback_interval("/interval",data, chat_id) do
#     IO.inspect(data)
#     # attr = %{"interval" => interval_string}
#     # case Library.Intervals.update_or_create_interval(attr) do
#     #   {:ok, interval} ->
#     #     IO.inspect(interval)
#     #     Telegram.sendMessage("Interval updated to #{interval_string} seconds.", chat_id)

#     #   _ ->
#     #     # Handle unexpected return values or errors
#     #     IO.puts("Error updating or creating interval.")
#     #end
#   end


# end
