# defmodule Library.TelPoller do
#   use GenServer
#   alias LibraryWeb.TelegramController, as: Telegram
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

#   #process message
#   def process_message(%{"text" => text, "chat" => %{"id" => chat_id} = chat} = message) do
#     case text do
#       "/start" -> process_text_message(text, chat_id, chat["username"], message["from"]["id"])
#       "/list" -> process_text_message(text, chat_id, chat["username"], message["from"]["id"])
#       "/parse" -> process_text_message(text, chat_id, chat["username"], message["from"]["id"])
#       _ -> IO.inspect(text) # Handle unknown or unsupported commands
#     end
#   end

#   def process_message(%{"text" => text, "chat" => %{"id" => chat_id}} = message)
#       when is_binary(text) do
#     username = Map.get(message, ["chat", "username"])
#     user_id = Map.get(message, ["from", "id"])
#     process_text_message(text, chat_id, username, user_id)
#   end
#   def send_file_received_message(text, chat_id) do
#     Telegram.sendMessage(text, chat_id)
#   end

#   def send_welcome_message(chat_id) do
#     Telegram.sendMessage("Welcome to the bot!", chat_id)
#   end

#   def send_echo(text, chat_id) do
#     Telegram.sendMessage("Did you just said: #{text}", chat_id)
#   end

#   def process_text_message("/start", chat_id, username, user_id) do
#     case Library.Users.user_exists_by_telegram_id?(user_id) do
#       false ->
#         current_time = DateTime.utc_now() |> DateTime.to_string()
#         user_attrs = %{"telegram_id" => user_id, "name" => username, "timestamp" => current_time}
#         IO.inspect(user_attrs)
#         Library.Users.create_user(user_attrs)

#         Telegram.sendMessage(
#           "Welcome to the Library Bot. Your account has been created, with #{username}",
#           chat_id
#         )

#       true ->
#         Telegram.sendMessage("Hey #{username} Welcome back to the Library Bot.", chat_id)
#     end
#   end

#   def process_text_message(text, chat_id, _username, _user_id) do
#     case text do
#       "/parse" -> process_parse("/parse", chat_id)
#       "/intrerval" -> process_intervel("/interval", chat_id)
#       _ -> process_text(text, chat_id)
#     end
#   end

#   # def process_message(
#   #       %{"document" => %{"file_id" => file_id}, "chat" => %{"id" => chat_id}} = message
#   #     ) do
#   #   process_document(file_id, chat_id)
#   # end

#   # def process_edited_message(message) do
#   #   process_message(message)
#   # end

#   # def process_message(message) do
#   #   Telegram.sendMessage("Received message: #{inspect(message)}", message["chat"]["id"])
#   # end

#   # def process_message(_message) do
#   #   Logger.error("Unexpected message format:")
#   # end

# #process update
# def process_update(
#   %{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} =
#     update
# ) do
# # Your existing code for handling the update
# response_message = "You selected: #{data}"
# Telegram.sendMessage(response_message, chat_id)

# try do
# case Telegram.iterate_through_map(data) do
#   :ok ->
#     Telegram.iterate_through_map(data)

#   _ ->
#     Telegram.sendMessage("Nothing Left...", chat_id)
# end
# rescue
# exception ->
#   error_response = handle_errors(exception)

#   error_message =
#     case error_response do
#       {:error, :case_clause_error} -> "A case clause error occurred #{:case_clause_error}."
#       {:error, :key_missing} -> "A required key is missing ."
#       {:error, :unknown_error} -> "An unexpected error occurred #{:unknown_error}."
#     end

#   Telegram.sendMessage("An unexpected error occurred: #{error_message}", chat_id)
# end
# end
# def process_update(update) do
# case update do
# %{"message" => message} -> process_message(message)
# %{"edited_message" => message} -> process_edited_message(message)
# end
# end



# #error handling
# def handle_errors(%CaseClauseError{term: term}) do
#   Logger.error("Encountered a case clause error with term: #{inspect(term)}")
#   {:error, :case_clause_error}
# end

# def handle_errors(%KeyError{key: key}) do
#   Logger.error("Key error: the key #{inspect(key)} is missing.")
#   {:error, :key_missing}
# end

# def handle_errors(_error) do
#   Logger.error("An unexpected error occurred on handle error.")
#   {:error, :unknown_error}
# end
# def handle_callback_data(_chat_id) do
# end






# #other process
# def process_parse("/parse", chat_id) do
#   list = Library.Contents.list_contents()
#   # book_name = Library.Contents.get_content_name(list)
#   books_list =
#     Enum.map(list, fn book ->
#       "#{book.chapter}#{book.data["author"]}"
#     end)

#   send_books_list(books_list, "Here are the list of books, please select one:", chat_id)
# end

# def process_intervel("/interval", chat_id) do
#   list = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
#   send_books_list(list, "Select the interval:", chat_id)
# end

# def process_text(text, chat_id) do
#   send_echo(text, chat_id)
# end
# def process_callback_query(%{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}) do
#   case data do
#     "some_callback_data" ->
#       handle_callback_data(chat_id)

#     _ ->
#       :ok
#   end
# end


# #funtions
# def send_books_list(list_of_books, text_input, chat_id) do
#   buttons = Enum.map(list_of_books, &option_maker/1)
#   IO.inspect(buttons)

#   keyboard_markup = %{
#     inline_keyboard: Enum.map(buttons, fn button -> [button] end)
#   }

#   Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
# end

# def option_maker(book_name) do
#   %{text: book_name, callback_data: book_name}
# end


# end





# #   def process_update(update) do
# #     first_name = update["message"]["from"]["first_name"]
# #     username = update["message"]["from"]["username"]
# #     chat_id = update["message"]["chat"]["id"]
# #     text = update["message"]["text"]
# #     message_id = update["message"]["message_id"]

# #     Logger.info("Received message from #{first_name} (#{username}): '#{text}' (Chat ID: #{chat_id}, Message ID: #{message_id})")

# # #    Here you can add logic to respond to the message or perform other actions
# #   end
# # Library.TelegramPoller.process_list("/list",977236716)

# #  def process_text_message("/parse", chat_id,_username, user_id) do
# #     active_book = Library.Books.
# #     list = Library.Books.get_book_data_by_name(active_book)
# #     case list do
# #       {:ok , data} -> x
# #       {:error, "Book not found"} -> Telegram.sendMessage("Book not found", chat_id)
# #     end
# #   end

# # def send_books_list(list_of_books, text_input, chat_id) do
# #   buttons = Enum.with_index(list_of_books, 1)
# #                 |> Enum.map(fn {_book_name, index} ->
# #                      option_maker("Chapter #{index}", index)
# #                    end)

# #   IO.inspect(buttons)

# #   keyboard_markup = %{
# #     inline_keyboard: Enum.map(buttons, fn button -> [button] end)
# #   }

# #   Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
# # end

# # def option_maker(display_text, index) do
# #   %{text: display_text, callback_data: "Chapter #{index}"}
# # end

# # def process_message(%{"document" => document, "chat" => %{"id" => chat_id}} = message) do
# #   mime_type = document["mime_type"]
# #   file_id = document["file_id"]

# #   # Check if the document is an ePub file
# #   if mime_type == "application/epub+zip" do
# #     process_epub_document(file_id, chat_id)
# #   else
# #     # Handle other file types or send an error message to the user
# #     Telegram.sendMessage("Please send an ePub file.", chat_id)
# #   end
# # end

# # def download_file(file_id) do
# #   # Use the getFile Telegram API method to get the file path
# #  # token = Application.get_env(:library, Library.TelegramBot)[:token]
# #  token = @token
# #   get_file_url = "#{@base_url}bot#{token}/getFile?file_id=#{file_id}"

# #   case HTTPoison.get(get_file_url) do
# #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
# #       file_path = Jason.decode!(body)["result"]["file_path"]
# #       download_url = "#{@base_url}file/bot#{token}/#{file_path}"

# #       # Now download the file. You might save it to a temporary location.
# #       # Ensure you have the necessary permissions and error handling.
# #       file_local_path = "path/to/save/#{file_path}" # Adjust this path as necessary
# #       {:ok, %HTTPoison.Response{status_code: 200, body: file_body}} = HTTPoison.get(download_url)
# #       File.write(file_local_path, file_body)

# #       {:ok, file_local_path}
# #     {:error, reason} ->
# #       {:error, reason}
# #   end
# # end

# # def download_file(file_id) do
# #   token = @token
# #   get_file_url = "#{@base_url}bot#{token}/getFile?file_id=#{file_id}"

# #   case HTTPoison.get(get_file_url) do
# #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
# #       file_path = Jason.decode!(body)["result"]["file_path"]
# #       download_url = "#{@base_url}file/bot#{token}/#{file_path}"

# #       # Attempt to download the file
# #       case HTTPoison.get(download_url) do
# #         {:ok, %HTTPoison.Response{status_code: 200, body: file_body}} ->
# #           # Save the file locally
# #           file_local_path = "path/to/save/#{file_path}" # Adjust as necessary
# #           File.write(file_local_path, file_body)
# #           {:ok, file_local_path}

# #         {:ok, %HTTPoison.Response{status_code: status_code}} ->
# #           {:error, "Failed to download file, status code: #{status_code}"}

# #         {:error, reason} ->
# #           {:error, reason}
# #       end

# #     {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
# #       {:error, "Failed to get file path, status code: #{status_code}, response: #{body}"}

# #     {:error, reason} ->
# #       {:error, reason}
# #   end
# # end
