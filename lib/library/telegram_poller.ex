defmodule Library.TelegramPoller do
  use GenServer
  alias LibraryWeb.MyFile
  alias Library.TelegramAPI
  alias LibraryWeb.TelegramController, as: Telegram
  alias Library.TelegramPoller.Process, as: Processor
  require Logger
  alias HTTPoison

  @api_url "https://api.telegram.org"
  @chat_id 977_236_716
  @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
  @base_url "https://api.telegram.org/"
  # GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec init(any()) :: {:ok, %{last_update_id: 0}}
  def init(_state) do
    schedule_polling()
    {:ok, %{last_update_id: 0}}
  end

  @spec schedule_polling() :: reference()
  def schedule_polling do
    Process.send_after(self(), :poll, 5_000)
  end

  def handle_info(:poll, state) do
    # Logger.info("Polling for updates...")
    new_state = fetch_updates(state)
    schedule_polling()
    {:noreply, new_state}
  end

  def fetch_updates(%{last_update_id: last_update_id} = state) do
    # Logger.info("Fetching updates...")
    token = Application.get_env(:library, Library.TelegramBot)[:token]

    case Library.TelegramAPI.get_updates(token, last_update_id) do
      {:ok, updates} when updates != [] ->
        Enum.each(updates, &process_update/1)

        new_last_update_id =
          updates
          |> Enum.max_by(fn update -> update["update_id"] end)
          |> Map.get("update_id")
          |> Kernel.+(1)

        %{state | last_update_id: new_last_update_id}

      {:ok, _updates} ->
        state

      {:error, reason} ->
        Logger.error("Failed to fetch updates: #{inspect(reason)}")
        state
    end
  end
  def reset_poller() do
    poller_pid = self()
    case GenServer.stop(poller_pid, :normal, :infinity) do
      :ok ->
        restart_poller()
      {:error, reason} ->
        Logger.error("Failed to stop poller: #{inspect(reason)}")
    end
  end

  defp restart_poller() do
    # Start a new instance of the Library.TelegramPoller GenServer
    case Library.TelegramPoller.start_link([]) do
      {:ok, new_poller_pid} ->
        Logger.info("Poller restarted with PID: #{inspect(new_poller_pid)}")
      {:error, reason} ->
        Logger.error("Failed to restart poller: #{inspect(reason)}")
    end
  end
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end





  def process_update(update) do
    #try do
      # Your existing process_update logic
      case update do
        %{
          "callback_query" => %{
            "data" => data,
            "message" => %{
              "chat" => %{
                "first_name" => first_name,
                "id" => chat_id,
                "last_name" => last_name,
                "username" => username
              }
            },
            "date" => 1711290633,
            "text" => in_text
          }
        } ->
            process_callback_query(data, chat_id, first_name, last_name, username,in_text)
         %{"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name,"username" => username},"text" => text } } ->
            process_text_message(text, chat_id, first_name, last_name, username)
         %{
          "message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name,"username" => username},
          "document" => %{"file_id" => file_id,"file_name" => file_name,"mime_type" => "application/epub+zip"}}} -> IO.inspect(update)
           #  process_documents(first_name, last_name, username, chat_id, file_id, file_name)
         _-> IO.inspect(update)
      end

  end

    def process_text_message(text, chat_id, first_name, last_name, username) do
      case text do
        "/chapter" -> Processor.process_chapter("/chapter", chat_id)
        "/list" -> Processor.process_list("/list", chat_id,username)
        "/interval" -> Processor.process_intervel("/interval", chat_id)
        "/start" -> Processor.process_start("/start", chat_id, first_name, last_name, username)
        _ -> Processor.process_text(text, chat_id)
      end
    end


  def process_callback_query(data, chat_id, first_name, last_name, username,in_text) do
    case in_text do
      "Here are the list of Chapters, please select one:"-> Processor.handle_callback_chapter("/chapter",data, chat_id)
      "Here are the list of books, please select one:"-> Processor.handle_callback_list("/list", chat_id,data,username)
      "Select the interval:"-> Processor.handle_callback_interval("/interval",data, chat_id)
      _ -> Telegram.sendMessage("Some Issue with the call back", @chat_id)
    end
  end
end
defmodule Library.TelegramPoller.Process do
  use GenServer
  alias LibraryWeb.MyFile
  alias Library.TelegramAPI
  alias LibraryWeb.TelegramController, as: Telegram
  alias Library.TelegramPoller.Process, as: Processor
  require Logger
  alias HTTPoison

  @api_url "https://api.telegram.org"
  @chat_id 977_236_716
  @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
  @base_url "https://api.telegram.org/"
  def process_start("/start", chat_id, first_name, last_name, username) do
    case Library.Users.get_user_telegram_id_by_name(username) do
      true ->
        Telegram.sendMessage(
          "Hey #{first_name} #{last_name} Welcome back to the Library Bot.",
          chat_id
        )
        {:error, :not_found} ->
          Telegram.sendMessage("User not found. Please try again.", chat_id)
      _->
        current_time = DateTime.utc_now() |> DateTime.to_string()
        collection_id = :rand.uniform(1000_000_000) |> Kernel.+(chat_id)

        user_attrs = %{
          "telegram_id" => chat_id,
          "name" => username,
          "first_name" => first_name,
          "last_name" => last_name,
          "timestamp" => current_time
        }

        IO.inspect(user_attrs)

        {:ok, user} = Library.Users.create_user(user_attrs)

        collection_attrs = %{"timestamp" => current_time, "user_id" => user.id}
        IO.inspect(collection_attrs)

        {:ok, collection} = Library.Collections.create_collection(collection_attrs)
        IO.inspect(collection)

        Telegram.sendMessage(
          "Welcome to the Library Bot. Your account has been created, with #{first_name} #{last_name}",
          chat_id
        )


    end
  end
  def process_list("/list", chat_id, username) do
    case Library.Users.get_user_telegram_id_by_name(username) do
      {:ok, decimal} ->
        user_id = Decimal.to_integer(decimal)
        IO.inspect(user_id)

        books = Library.Books.get_books_by_user_id(user_id)
        IO.inspect(books)
        if Enum.empty?(books) do
          Telegram.sendMessage("You haven't added any books yet. Please upload a book first.", chat_id)
        else
          list = Enum.map(books, fn book -> book["name"] end)
          send_books_list(list, "Here are the list of books, please select one:", chat_id, "/list")
        end

      {:error, :not_found} ->
        Telegram.sendMessage("User not found. Please try again.", chat_id)

      {:error, reason} ->
        Telegram.sendMessage("An error occurred: #{inspect(reason)}", chat_id)
    end
  end
  @spec process_chapter(<<_::64>>, any()) :: any()
  def process_chapter("/chapter", chat_id) do
    list = Library.Contents.list_contents()
    IO.inspect(list)
    if Enum.empty?(list) do
      Telegram.sendMessage(
        "There are no chapters available. Please upload a book first.",
        chat_id
      )
    else
      # books_list =
      #   Enum.map(list, fn book ->
      #     "#{book.chapter}#{book.data["author"]}"
      #   end)

        list = Library.Contents.list_contents()
        books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
        send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
      end
  end

  def process_intervel("/interval", chat_id) do
    interval_options = ["5", "30", "60", "300", "1800", "3600", "7200", "14400"]

    interval_labels = ["5 Sec","30 Sec","1 Mins","5 Mins","30 Mins","1 Hrs"]

    send_interval_options(interval_options, interval_labels, "Select the interval:", chat_id)
  end
  #call backs

  def handle_callback_list("/list", chat_id,data, user_id) do
    IO.inspect(data)
    # books = Library.Books.get_books_by_user_id(user_id)
    # list = Enum.map(books, fn book -> book["name"] end)
   # send_books_list(list, "Here are the list of books, please select one:", chat_id)
  end

  def handle_callback_chapter("/chapter", data,chat_id) do
    IO.inspect(data)
    # list = Library.Contents.list_contents()
    # books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
    # send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
  end

  def handle_callback_interval("/interval",data, chat_id) do
    IO.inspect(data)
    # attr = %{"interval" => interval_string}
    # case Library.Intervals.update_or_create_interval(attr) do
    #   {:ok, interval} ->
    #     IO.inspect(interval)
    #     Telegram.sendMessage("Interval updated to #{interval_string} seconds.", chat_id)

    #   _ ->
    #     # Handle unexpected return values or errors
    #     IO.puts("Error updating or creating interval.")
    #end
  end




  def process_documents(first_name,last_name, username, chat_id, file_id, file_name) do
    Telegram.get_file(file_id)
    |> case do
      {:ok, %{"file_path" => file_path}} ->
        IO.inspect(file_path)
        path = "#{@api_url}/file/bot#{@token}/#{file_path}"

        HTTPoison.get(path)
        |> IO.inspect()
        |> case do
          {:ok, %HTTPoison.Response{body: data}} ->
            local_file_path = Path.join(["lib", "library", "files", file_name])
            write_file(local_file_path, data)
            {:ok, decimal}  =  Library.Users.get_user_telegram_id_by_name(username)
            user_id = Decimal.to_integer(decimal)
            IO.inspect(user_id)

            changeset =
              %Library.Schema.Book{}
              |> Ecto.Changeset.change(%{name: file_name, user_id: 1})

            IO.inspect(changeset)

            case Library.Repo.insert(changeset) do
              {:ok, _record} ->
                Telegram.sendMessage("#{first_name} inserted #{file_name} successfully.", chat_id)

              {:error, changeset} ->
                IO.inspect(changeset.errors)
            end
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        Telegram.sendMessage("Request timed out. Please try again later.", chat_id)

      {:error, error} ->
        IO.inspect(error, label: "Unexpected Error")
    end
    |> LibraryWeb.LibraryController.unzip_epub()
  end

  def handle_callback_chapter("/chapter", chat_id) do
    list = Library.Contents.list_contents()
    books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
    send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
  end

  def handle_callback_interval(interval_string, chat_id) do
    attr = %{"interval" => interval_string}

    case Library.Intervals.update_or_create_interval(attr) do
      {:ok, interval} ->
        IO.inspect(interval)
        Telegram.sendMessage("Interval updated to #{interval_string} seconds.", chat_id)

      _ ->
        # Handle unexpected return values or errors
        IO.puts("Error updating or creating interval.")
    end
  end

  def handle_callback_list("/list", chat_id, user_id) do
    books = Library.Books.get_books_by_user_id(user_id)
    list = Enum.map(books, fn book -> book["name"] end)
    send_books_list(list, "Here are the list of books, please select one:", chat_id)
  end

  # process_messages / others

  # def process_text_message(text, chat_id, first_name, last_name, username) do
  #   case text do
  #     "/chapter" -> process_chapter("/chapter", chat_id)
  #     "/list" -> process_list("/list", chat_id,username)
  #     "/interval" -> process_intervel("/interval", chat_id)
  #     "/start" -> process_start("/start", chat_id, first_name, last_name, username)
  #     _ -> process_text(text, chat_id)
  #   end
  # end

  # def process_list("/list", chat_id,username) do
  #   {:ok, decimal}  =  Library.Users.get_user_telegram_id_by_name(username)
  #   user_id = Decimal.to_integer(decimal)
  #   IO.inspect(user_id)

  #   books = Library.Books.get_books_by_user_id(user_id)
  #   IO.inspect(books)
  #   if Enum.empty?(books) do
  #     Telegram.sendMessage(
  #       "You haven't added any books yet. Please upload a book first.",
  #       chat_id
  #     )
  #   else
  #     list = Enum.map(books, fn book -> book["name"] end)
  #     send_books_list(list, "Here are the list of books, please select one:", chat_id)
  #   end
  # end

  # def process_chapter("/chapter", chat_id) do
  #   list = Library.Contents.list_contents()
  #   IO.inspect(list)
  #   if Enum.empty?(list) do
  #     Telegram.sendMessage(
  #       "There are no chapters available. Please upload a book first.",
  #       chat_id
  #     )
  #   else
  #     # books_list =
  #     #   Enum.map(list, fn book ->
  #     #     "#{book.chapter}#{book.data["author"]}"
  #     #   end)

  #       list = Library.Contents.list_contents()
  #       books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
  #       send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
  #     end
  # end

  # def process_intervel("/interval", chat_id) do
  #   interval_options = ["5", "30", "60", "300", "1800", "3600", "7200", "14400"]

  #   interval_labels = [
  #     "5 Sec",
  #     "30 Sec",
  #     "60 Sec",
  #     "5 Mins",
  #     "30 Mins",
  #     "60 Mins",
  #     "2 Hrs",
  #     "4 Hrs"
  #   ]

  #   send_interval_options(interval_options, interval_labels, "Select the interval:", chat_id)
  # end
  defp send_interval_options(options, labels, text_input, chat_id) do
    buttons = Enum.zip(options, labels) |> Enum.map(&encode_button/1)

    keyboard_markup = %{
      inline_keyboard: [buttons]
    }

    case Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup)) do
      {:ok, response} ->
        message_text = Map.get(response, "text", "Unknown")
        LibraryWeb.TelegramController.sendMessage(message_text, chat_id)

      {:error, reason} ->
        Logger.error("Failed to send message: #{inspect(reason)}")
        :error
    end
  end

  defp encode_button({option, label}) do
    %{text: label, callback_data: "/interval #{option}"}
  end

  def update_interval(new_interval) do
    # Update the interval in your application state or configuration
    # Example:
    Application.put_env(:library, :interval, new_interval)
  end

  def process_text(text, chat_id) do
    send_echo(text, chat_id)
  end



  def download_epub(file_url) do
    case HTTPoison.get(file_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: file_content}} ->
        # Save the file content to the desired location
        save_file(file_content)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP Error: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{inspect(reason)}"}
    end
  end

  def save_file(file_content) do
    file_path = Path.join([:code.priv_dir(:library), "downloads", "file.epub"])
    File.write(file_path, file_content)
  end

  defp write_file(path, data) do
    # Ensure the directory exists
    File.mkdir_p(Path.dirname(path))

    # Write the binary data to the file
    case File.write(path, data) do
      :ok -> IO.puts("File written successfully to #{path}")
      {:error, reason} -> IO.puts("Error writing to file: #{inspect(reason)}")
    end
  end

  # error handling
  def handle_errors(%CaseClauseError{term: term}) do
    Logger.error("Encountered a case clause error with term: #{inspect(term)}")
    {:error, :case_clause_error}
  end

  def handle_errors(%KeyError{key: key}) do
    Logger.error("Key error: the key #{inspect(key)} is missing.")
    {:error, :key_missing}
  end

  def handle_errors(_error) do
    Logger.error("An unexpected error occurred on handle error.")
    {:error, :unknown_error}
  end

  def handle_callback_data(_chat_id) do
  end

  # other process

  def send_echo(text, chat_id) do
    Telegram.sendMessage("Did you just said: #{text}", chat_id)


  end
  # funtions

  def send_books_list(list_of_books, text_input, chat_id, callback_data_prefix \\ "") do
    buttons = Enum.map(list_of_books, &option_maker(&1, callback_data_prefix))

    keyboard_markup = %{
      inline_keyboard: Enum.map(buttons, fn button -> [button] end)
    }

    Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
  end

  def option_maker(book_name) do
    %{text: book_name, callback_data: book_name}
  end
  def option_maker(book_name, callback_data_prefix) do
    %{text: book_name, callback_data: "#{callback_data_prefix}#{book_name}"}
  end
end
