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



  def handle_update(update, _context) do
    case update do
      %{"message" => message} ->
        process_message(message)
      %{"edited_message" => message} ->
        process_edited_message(message)
      %{"callback_query" => callback_query} ->
        process_callback_query(callback_query)
      _ ->
        :ok
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

  def process_message(%{"text" => text, "chat" => %{"id" => chat_id}}) do
    process_text_message(text, chat_id)
  end

  def process_message(%{"document" => %{"mime_type" => "application/epub+zip"} = document, "chat" => %{"id" => chat_id}}) do
    process_epub_file(document, chat_id)
  end

  # This clause handles cases not covered by the specific patterns above.
  def process_message(_message) do
    # Log or handle unexpected message formats
  end

  def process_text_message("/start", chat_id) do
    send_welcome_message(chat_id)
  end
  def process_text_message("/list", chat_id) do
    send_welcome_message(chat_id)
  end
  def process_text_message("/interval", chat_id) do
    send_welcome_message(chat_id)
  end
  def process_text_message("/parse", chat_id) do
    send_welcome_message(chat_id)
  end
  def process_text_message(text, chat_id) do
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
