defmodule Library.TelegramPoller do
  use GenServer
  alias LibraryWeb.TelegramController ,as: Telegram
  require Logger

  # GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  def init(_state) do
    schedule_polling()
    {:ok, %{last_update_id: 0}}
  end
  @spec schedule_polling() :: reference()
  def schedule_polling do
      Process.send_after(self(), :poll, 5_000)
    end
  def handle_info(:poll, state) do
    # Pass the current state to fetch_updates
    new_state = fetch_updates(state)
    schedule_polling()
    {:noreply, new_state}
  end

  def fetch_updates(%{last_update_id: last_update_id} = state) do
    token = Application.get_env(:library, Library.TelegramBot)[:token]
    case Library.TelegramAPI.get_updates(token, last_update_id) do
      {:ok, updates} when updates != [] ->
        Enum.each(updates, &process_update/1)

        new_last_update_id = updates
                             |> Enum.max_by(fn update -> update["update_id"] end)
                             |> Map.get("update_id")
                             |> Kernel.+(1)

        # Return the updated state with the new last_update_id
        %{state | last_update_id: new_last_update_id}

      {:ok, _updates} ->
        # No new updates, return the state unchanged
        state

      {:error, reason} ->
        Logger.error("Failed to fetch updates: #{inspect(reason)}")
        # Return the state unchanged
        state
    end
  end


  # Define more functions for other update types...


  def first_name(update) , do: update["message"]["from"]["first_name"]
  def username(update) ,do: update["message"]["from"]["username"]
  def chat_id(update) ,do: update["message"]["chat"]["id"]
  def text(update) ,do: update["message"]["text"]




    # Assuming your Library.ErrorHandler module and other necessary modules (like Telegram) are defined elsewhere
    def handle_errors(%CaseClauseError{term: term}) do
      Logger.error("Encountered a case clause error with term: #{inspect(term)}")
      {:error, :case_clause_error}
    end

    def handle_errors(%KeyError{key: key}) do
      Logger.error("Key error: the key #{inspect(key)} is missing.")
      {:error, :key_missing}
    end

    # A catch-all for any other errors not explicitly matched above
    def handle_errors(_error) do
      Logger.error("An unexpected error occurred.")
      {:error, :unknown_error}
    end
    def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} = update) do
      # Your existing code for handling the update

      response_message = "You selected: #{data}"
      Telegram.sendMessage(response_message, chat_id)

      try do
        case Telegram.iterate_through_map(data) do
          :ok ->
            # Handle the case when the result is just the atom :ok
            # You might want to add specific error handling or additional logic here
            Telegram.iterate_through_map(data)
          _ ->
            Telegram.sendMessage("Error Occured", chat_id)
            # Handle the case when the result is not the expected tuple {:ok, _}
            # You can add specific error handling or additional logic here
        end

      rescue
        exception ->
          # Now using the Library.ErrorHandler to process the exception
          error_response = handle_errors(exception)

          # Extracting the error message based on the error_response tuple
          error_message = case error_response do
            {:error, :case_clause_error} -> "A case clause error occurred."
            {:error, :key_missing} -> "A required key is missing."
            {:error, :unknown_error} -> "An unexpected error occurred."
          end

          Telegram.sendMessage("An unexpected error occurred: #{error_message}", chat_id)
      end
    end

  def process_update(%{"message" => message} = update) do
    process_message(message)
  end
  def process_update(%{"edited_message" => message} = update) do
    process_edited_message(message)
  end
  def process_update(update) do
    first_name = update["message"]["from"]["first_name"]
    username = update["message"]["from"]["username"]
    chat_id = update["message"]["chat"]["id"]
    text = update["message"]["text"]
    message_id = update["message"]["message_id"]

    Logger.info("Received message from #{first_name} (#{username}): '#{text}' (Chat ID: #{chat_id}, Message ID: #{message_id})")

#    Here you can add logic to respond to the message or perform other actions
  end



  def process_edited_message(message) do
    # Your logic for processing an edited message
    process_message(message)
  end

  def process_message(%{"text" => text, "chat" => %{"id" => chat_id,"username" => username,"user_id" => user_id}}) do
    process_text_message(text, chat_id, username, user_id)
  end

  def process_message(%{"document" => %{"mime_type" => "application/epub+zip"} = document, "chat" => %{"id" => chat_id}}) do
    process_epub_file(document, chat_id)
  end

  # This clause handles cases not covered by the specific patterns above.
  def process_message(_message) do
    # Log or handle unexpected message formats
  end

  def process_text_message("/start", chat_id, username,user_id) do
    case   Library.Users.user_exists_by_telegram_id?(user_id) do
      false ->
        # User does not exist, create a new one
        user_attrs = %{"telegram_id" => user_id, "name" => username}
        Library.Users.create_user(user_attrs)

        Telegram.sendMessage("Welcome to the Library Bot. Your account has been created, with #{username}",chat_id)

      true ->
        # User already exists
        Telegram.sendMessage("Hey #{username} Welcome back to the Library Bot.",chat_id)
    end
  end
  # def process_text_message("/list", chat_id,_username, _user_id) do
  #   list = Library.Collections.list_collections
  #   Enum.map(list, fn item ->
  #     LibraryWeb.TelegramController.sendMessage(item, chat_id)
  #   end)
  # end


  def process_text_message("/list", chat_id, _username, _user_id) do
    list = Library.Books.list_books()

    books_list = Enum.map(list, fn book ->
      "#{book.name}#{book.data["author"]}" # Assuming book.data is a map with author. Adjust as necessary.
    end)

    send_books_list(books_list, "Here are the list of books, please select one:", chat_id)
  end

  def send_books_list(list_of_books, text_input, chat_id) do
    buttons = Enum.map(list_of_books, &option_maker/1)

    # Making sure each button is in its own row
    keyboard_markup = %{
      inline_keyboard: Enum.map(buttons, fn button -> [button] end)
    }

    Telegram.req(chat_id,text_input,Jason.encode!(keyboard_markup))
  end

  def option_maker(book_name) do
    %{text: book_name, callback_data: book_name}
  end
  def process_text_message("/interval", chat_id,_username, _user_id) do
    send_welcome_message(chat_id)
  end

  def process_text_message(text, chat_id,_username, _user_id) do
    send_echo(text, chat_id)
  end


  def process_epub_file(document, chat_id) do
    file_name= document["file_name"]
    send_file_received_message("Received your EPUB file! (#{file_name})", chat_id)
  end

  def send_file_received_message(text, chat_id) do
    Telegram.sendMessage(text, chat_id)
  end

  def send_welcome_message(chat_id) do
    Telegram.sendMessage("Welcome to the bot!", chat_id)
  end

  def send_echo(text, chat_id) do
    Telegram.sendMessage("You said: #{text}", chat_id)
  end

  def process_callback_query(%{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}) do
    case data do
      "some_callback_data" ->
        handle_callback_data(chat_id)
      _ ->
        :ok
    end
  end
  def handle_callback_data(_chat_id) do
    # Handle your callback data here
  end
end
  # def handle_info(:poll, state) do
  #   fetch_updates() # Replace with actual logic to fetch updates from Telegram

  #   schedule_polling() # Reschedule the next poll
  #   {:noreply, state}
  # end
   # def start_link(args) do
  #   GenServer.start_link(__MODULE__, args)
  # end
  # def init(_) do
  #   schedule_polling() # Start the polling process
  #   {:ok, %{}}
  # end


  # def process_update(update) do
  #   # Process each update
  #   Logger.info("Received update: #{inspect(update)}")
  #   # Further processing
  # end


  # def init(_state) do
  #   schedule_polling()
  #   {:ok, %{}}
  # end
  # # Handle the polling
  # def handle_info(:poll, state) do
  #   fetch_updates()
  #   schedule_polling()
  #   {:noreply, state}
  # end

  # def schedule_polling do
  #   Process.send_after(self(), :poll, 5_000)
  # end

  # def fetch_updates do
  #   # logic to fetch and process Telegram updates callingTelegram API and handling response
  #   token = Application.get_env(:library, Library.TelegramBot)[:token]
  #   case Library.TelegramAPI.get_updates(token) do
  #     {:ok, updates} ->
  #       Enum.each(updates, &process_update/1)
  #     {:error, reason} ->
  #       Logger.error("Failed to fetch updates: #{inspect(reason)}")
  #   end
  # end
 # def handle_info(:poll, state) do
  #   fetch_updates(state.last_update_id)
  #   schedule_polling()
  #   {:noreply, state}
  # end

  # def fetch_updates(last_update_id) do
  #   token = Application.get_env(:library, Library.TelegramBot)[:token]
  #   case Library.TelegramAPI.get_updates(token, last_update_id) do
  #     {:ok, updates} ->
  #       new_last_update_id = Enum.reduce(updates, last_update_id, fn update, acc ->
  #         process_update(update)
  #         max(acc, update["update_id"])
  #       end)
  #       {:noreply, %{state | last_update_id: new_last_update_id}}
  #     {:error, reason} ->
  #       Logger.error("Failed to fetch updates: #{inspect(reason)}")
  #       {:noreply, state}
  #   end
  # end
#   def process_update(update) do
#     # first_name = update["message"]["from"]["first_name"]
#     # username = update["message"]["from"]["username"]
#     # chat_id = update["message"]["chat"]["id"]
#     # text = update["message"]["text"]
#     # message_id = update["message"]["message_id"]

#    # Logger.info("Received message from #{first_name} (#{username}): '#{text}' (Chat ID: #{chat_id}, Message ID: #{message_id})")
# Logger.info(update)
# #    Here you can add logic to respond to the message or perform other actions
#   end

  # def fetch_updates(state) do
  #   token = Application.get_env(:library, Library.TelegramBot)[:token]
  #   case Library.TelegramAPI.get_updates(token) do
  #     {:ok, updates} ->
  #       Enum.each(updates, &process_update/1)
  #       # Return the updated state if necessary
  #       state
  #     {:error, reason} ->
  #       Logger.error("Failed to fetch updates: #{inspect(reason)}")
  #       # Return the state unchanged
  #       state
  #   end
  # end


# [{"message", %{"chat" => %{"first_name" => "Wania", "id" => 977236716, "last_name" => "#", "type" => "private", "username" => "Lau_riel"}, "date" => 1710398810, "from" => %{"first_name" => "Wania", "id" => 977236716, "is_bot" => false, "language_code" => "en", "last_name" => "#", "username" => "Lau_riel"}, "message_id" => 1025, "text" => "ju"}}, {"update_id", 231984446}]
# [{"edited_message", %{"chat" => %{"first_name" => "Wania", "id" => 977236716, "last_name" => "#", "type" => "private", "username" => "Lau_riel"}, "date" => 1710398810, "edit_date" => 1710398835, "from" => %{"first_name" => "Wania", "id" => 977236716, "is_bot" => false, "language_code" => "en", "last_name" => "#", "username" => "Lau_riel"}, "message_id" => 1025, "text" => "juO"}}, {"update_id", 231984447}]
#  [{"message", %{"caption" => "new", "chat" => %{"first_name" => "Wania", "id" => 977236716, "last_name" => "#", "type" => "private", "username" => "Lau_riel"}, "date" => 1710398864, "document" => %{"file_id" => "BQACAgUAAxkBAAIEAmXynZAYDwh-R5FgGLlpIAn3S8UlAAK2DgACGPiZVyWWnrV3GcWUNAQ", "file_name" => "osdc_Jim-Hall_C-Programming-Tips.epub", "file_size" => 694585, "file_unique_id" => "AgADtg4AAhj4mVc", "mime_type" => "application/epub+zip"}, "from" => %{"first_name" => "Wania", "id" => 977236716, "is_bot" => false, "language_code" => "en", "last_name" => "#", "username" => "Lau_riel"}, "message_id" => 1026}}, {"update_id", 231984448}]
# iex(1)>
  # def handle_update(update, _context) do
  #   case update do
  #     %{"message" => message} ->
  #       process_message(message)
  #     %{"edited_message" => message} ->
  #       process_edited_message(message)
  #     %{"callback_query" => callback_query} ->
  #       process_callback_query(callback_query)
  #     _ ->
  #       :ok
  #   end
  # end
  # def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} = update) do
  #   case data do
  #     "option_1" -> Telegram.sendMessage("You selected option 1", chat_id)
  #     "option_2" -> Telegram.sendMessage("You selected option 2", chat_id)
  #     "option_3" -> Telegram.sendMessage("You selected option 3", chat_id)
  #     _ -> :ignore
  #   end
  # end
  # def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} = update) do
  #   # Assuming `data` contains the exact book name or a unique identifier,
  #   # You might need to fetch the book details from your database if `data` is an identifier.

  #   response_message = "You selected: #{data}"
  #   Telegram.sendMessage(response_message, chat_id)
  #   try do
  #     case Telegram.iterate_through_map(data) do
  #       {:ok, result} ->
  #         Telegram.iterate_through_map(result)
  #         {:error, "Book not found"}  ->
  #         # Handle the error, possibly sending a message back to the user
  #         Telegram.sendMessage("Book not found", chat_id)
  #     end
  #   rescue
  #     exception ->
  #       # Handle any exceptions that were raised during the execution
  #       Telegram.sendMessage("An unexpected error occurred: #{exception.message}", chat_id)
  #   end
  # end

  # def process_text_message("/list", chat_id, _username, _user_id) do
  #   list = Library.Books.list_books()
  #   Telegram.button(list, "Here are the list of books, please select one:", chat_id)
  # end
    #  fn item ->
    #   # Create a message string from the collection item
    #   message = "Collection ID: #{item.id}, Book Name #{item.name}"

    #   # Now pass this message string to sendMessage, along with the chat_id
    #   LibraryWeb.TelegramController.sendMessage(message, chat_id)
    # end)
  #end


  # def process_text_message("/parse", chat_id,_username, user_id) do
  #   active_book =
  #   list = Library.Books.get_book_data_by_name(active_book)
  #   case list do
  #     {:ok , data} -> _x
  #     {:error, "Book not found"} -> Telegram.sendMessage("Book not found", chat_id)
  #   end
  # end

    # def handle_info(:poll, state) do
  #   # Initial call to fetch_updates
  #   result = fetch_updates(state)

  #   # Pass the result through handle_fetch_updates_result for further processing
  #   new_state = case result do
  #     {:ok, updated_state} -> handle_fetch_updates_result({:ok, updated_state}, state)
  #     {:error, _reason} = error -> handle_fetch_updates_result(error, state)
  #     _unexpected_result ->
  #       Logger.error("Unexpected result from fetch_updates: #{inspect(_unexpected_result)}")
  #       state
  #   end

  #   schedule_polling()
  #   {:noreply, new_state}
  # end

  # defp handle_fetch_updates_result({:ok, updated_state}, _state), do: updated_state
  # defp handle_fetch_updates_result({:error, _reason}, state) do
  #   # Log the error and decide whether to modify the state or take other actions
  #   Logger.error("Failed to fetch updates: #{inspect(_reason)}")
  #   # Return the current state without changes
  #   state
  # end
   # case Telegram.iterate_through_map(data) do
        #   {:ok, result} ->
        #     # Assuming this function call should produce a side effect or is missing in this snippet
        #     Telegram.iterate_through_map(result)

        #   _ ->
        #     # Using the error handler directly might not be suitable here as this is a specific error case.
        #     # However, you should adapt your code to handle this more gracefully if needed.
        #     Telegram.sendMessage("Book not found", chat_id)
        # end
