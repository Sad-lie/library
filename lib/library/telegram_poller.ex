defmodule Library.TelegramPoller do
  use GenServer
  alias LibraryWeb.MyFile
  alias Library.TelegramAPI
  alias LibraryWeb.TelegramController, as: Telegram
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

  # process update


  def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}}) do
    response_message = handle_callback_data(data, chat_id)
    Telegram.sendMessage(response_message, chat_id)
  end

  def process_update(
  %{"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,"last_name" => last_name,"username" => username},"text" => text}})do
    process_text_message(text, chat_id, first_name, last_name, username, chat_id)
    end
  def process_update(%{
        "message" => %{
          "chat" => %{"first_name" => first_name, "id" => chat_id, "last_name" => last_name,"username" => username},
          "document" => %{"file_id" => file_id,"file_name" => file_name,"mime_type" => "application/epub+zip"}}}) do
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
            user_id = 2 #Library.Users.get_user_telegram_id_by_name(username)
            changeset =
            %Library.Schema.Book{}
            |> Ecto.Changeset.change(%{ name: file_name, user_id: user_id})
            IO.inspect(changeset)
          case Library.Repo.insert(changeset) do
            {:ok, _record} -> Telegram.sendMessage("#{first_name} inserted #{file_name} successfully.", chat_id)
            {:error, changeset} -> IO.inspect(changeset.errors)
          end
        end
        {:error, %HTTPoison.Error{reason: :timeout}} ->
          Telegram.sendMessage("Request timed out. Please try again later.", chat_id)
        {:error, error} ->
          IO.inspect(error, label: "Unexpected Error")
    end
     |> LibraryWeb.LibraryController.unzip_epub()
  end
  def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}}) do
    case String.split(data) do
      ["/interval", interval_string] ->
        handle_callback_data("/interval " <> interval_string, chat_id)

      _ ->
        response_message = "You selected: #{data}"
        Telegram.sendMessage(response_message, chat_id)

        try do
          case Telegram.iterate_through_map(data) do
            :ok ->
              Telegram.iterate_through_map(data)
            _ ->
              Telegram.sendMessage("Nothing Left...", chat_id)
          end
        rescue
          exception ->
            Logger.error("Error processing update: #{inspect(exception)}")

            error_response = handle_errors(exception)
            error_message = case error_response do
              {:error, :case_clause_error} -> "A case clause error occurred."
              {:error, :key_missing} -> "A required key is missing."
              {:error, :unknown_error} -> "An unexpected error occurred."
            end

            Telegram.sendMessage("An unexpected error occurred: #{error_message}", chat_id)
        end
    end
  end

  # def process_update(%{"callback_query" => %{"data" => interval_string, "message" => %{"chat" => %{"id" => chat_id}}}}) do
  #   case Integer.parse(interval_string) do
  #     {interval, _} ->
  #       Telegram.sendMessage("Interval updated to #{interval} seconds.", chat_id)
  #       update_interval(interval)
  #     :error ->
  #       Telegram.sendMessage("Invalid interval value. Please try again.", chat_id)
  #   end
  # end
  # def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}}) do
  #   response_message = "You selected: #{data}"
  #   Telegram.sendMessage(response_message, chat_id)

  #   try do
  #     case Telegram.iterate_through_map(data) do
  #       :ok ->
  #         Telegram.iterate_through_map(data)
  #       _ ->
  #         Telegram.sendMessage("Nothing Left...", chat_id)
  #     end
  #   rescue
  #     exception ->
  #       Logger.error("Error processing update: #{inspect(exception)}")

  #       error_response = handle_errors(exception)
  #       error_message = case error_response do
  #         {:error, :case_clause_error} -> "A case clause error occurred."
  #         {:error, :key_missing} -> "A required key is missing."
  #         {:error, :unknown_error} -> "An unexpected error occurred."
  #       end

  #       Telegram.sendMessage("An unexpected error occurred: #{error_message}", chat_id)
  #   end
  # end
  def process_update(%{"edited_message" => edited_message} = update) do
    # Handle the edited message update here
    IO.inspect(edited_message, label: "Edited Message")
  #  {:noreply, Map.put(state, :last_update_id, update["update_id"])}
  end

  def handle_callback_data("/parse", chat_id) do
    list = Library.Contents.list_contents()
    books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
    send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
  end
  def handle_callback_data("/interval " <> interval_string, chat_id) do
    case Integer.parse(interval_string) do
      {interval, _} ->
        update_interval(interval)
        Telegram.sendMessage("Interval updated to #{interval} seconds.", chat_id)
      :error ->
        Telegram.sendMessage("Invalid interval value. Please try again.", chat_id)
    end
  end


  def handle_callback_data("/list", chat_id, user_id) do
    books = Library.Books.get_books_by_user_id(user_id)
    list = Enum.map(books, fn book -> book["name"] end)
    send_books_list(list, "Here are the list of books, please select one:", chat_id)
  end


  #process_messages / others

  def process_text_message(text, chat_id,first_name,last_name, username, user_id) do
    case text do
      "/parse" -> process_parse("/parse", chat_id)
      "/list" -> process_list("/list", chat_id, user_id)
      "/interval" -> process_intervel("/interval", chat_id)
      "/start" -> process_start("/start", chat_id, first_name, last_name, username, user_id)
      _ -> process_text(text, chat_id)
    end
  end

  def process_list("/list", chat_id, user_id) do
    books = Library.Books.get_books_by_user_id(user_id)

    if Enum.empty?(books) do
      Telegram.sendMessage("You haven't added any books yet. Please upload a book first.", chat_id)
    else
      list = Enum.map(books, fn book -> book["name"] end)
      send_books_list(list, "Here are the list of books, please select one:", chat_id)
    end
  end

  def process_parse("/parse", chat_id) do
    list = Library.Contents.list_contents()

    if Enum.empty?(list) do
      Telegram.sendMessage("There are no chapters available. Please upload a book first.", chat_id)
    else
      books_list =
        Enum.map(list, fn book ->
          "#{book.chapter}#{book.data["author"]}"
        end)

      send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
    end
  end
  def process_intervel("/interval", chat_id) do
    interval_options = ["5", "30", "60", "300", "1800", "3600", "7200", "14400"]
    interval_labels = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
    send_interval_options(interval_options, interval_labels, "Select the interval:", chat_id)
  end

  # def process_intervel("/interval", chat_id) do
  #   list = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
  #   send_books_list(list, "Select the interval:", chat_id)

  # end

  # def handle_callback_data("/interval", chat_id) do
  #   list = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
  #   send_books_list(list, "Select the interval:", chat_id)
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

  def process_start("/start", chat_id,first_name,last_name, username, user_id) do
    case Library.Users.user_exists_by_telegram_id?(user_id) do
      false ->
        current_time = DateTime.utc_now() |> DateTime.to_string()
        collection_id = :rand.uniform(1000_000_000) |> Kernel.+(user_id)

        user_attrs = %{"telegram_id" => user_id, "name" => username,"first_name"=> first_name,"last_name"=> last_name, "timestamp" => current_time}
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

      true ->
        Telegram.sendMessage("Hey #{first_name} #{last_name} Welcome back to the Library Bot.", chat_id)
    end
  end


  def new do
    process_update(%{
      "message" => %{
        "chat" => %{
          "first_name" => "Wania",
          "id" => 977_236_716
        },
        "document" => %{
          "file_id" => "BQACAgUAAxkBAAIFrGX6fWnZ_UJ4hXx5uM0bvbYYKjfBAAKVCwACQ5HQVxaNimSepLuoNAQ",
          "file_name" => "Alices Adventures in Wonderland.epub",
          "file_size" => 885_898,
          "file_unique_id" => "AgADlQsAAkOR0Fc",
          "mime_type" => "application/epub+zip"
        }
      }
    })
    |> case do
      {:ok, %{"file_path" => file_path}} ->
        IO.inspect(file_path)
        path = "#{@api_url}/file/bot#{@token}/#{file_path}"

        case download_epub(path) do
          :ok ->
            IO.puts("File downloaded successfully")
            |> LibraryWeb.LibraryController.unzip_epub()

          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end

      _ ->
        {:error}
    end
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

  def send_books_list(list_of_books, text_input, chat_id) do
    buttons = Enum.map(list_of_books, &option_maker/1)
    IO.inspect(buttons)

    keyboard_markup = %{
      inline_keyboard: Enum.map(buttons, fn button -> [button] end)
    }

    Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
  end

  def option_maker(book_name) do
    %{text: book_name, callback_data: book_name}
  end
end
  # def process_callback_query(%{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}) do
  #   case data do
  #     "some_callback_data" ->
  #       handle_callback_data(chat_id)

  #     _ ->
  #       :ok
  #   end
  # end
# sendDocument([
#   'chat_id' => 'CHAT_ID',
#   'document' => 'path/to/document.pdf',
# 	'caption' => 'This is a document',
# ]);

# %{"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,},
# "document" => %{"file_id" => file_id,"file_name" => file_name,"file_size" => file_size,
# "file_unique_id" => file_unique_id,"mime_type" =>"application/epub+zip"}}}

# %{
#   "message" => %{
#     "chat" => %{
#       "first_name" => "Wania",
#       "id" => 977236716,
#     },
#     "document" => %{
#       "file_id" => "BQACAgUAAxkBAAIFrGX6fWnZ_UJ4hXx5uM0bvbYYKjfBAAKVCwACQ5HQVxaNimSepLuoNAQ",
#       "file_name" => "Alices Adventures in Wonderland.epub",
#       "file_size" => 885898,
#       "file_unique_id" => "AgADlQsAAkOR0Fc",
#       "mime_type" => "application/epub+zip"
#     }
#   }
# }

# Example usage:
# MyFileOperations.create_dir_and_write_file("my_new_directory", "my_file.txt", "Hello, Elixir!")

# process update
# def process_update(anything) do
#   IO.inspect(anything)
#   new()
# # end
# def process_update(%{"message" => %{"chat" => %{"first_name" => first_name, "id" => chat_id},
#   "document" => %{"file_id" => file_id, "file_name" => file_name, "file_size" => file_size,
#   "file_unique_id" => file_unique_id, "mime_type" => "application/epub+zip"}}}) do
#   case Telegram.get_file(file_id) do
#     {:ok, %{"file_path" => file_path}} ->
#       case Library.TelegramAPI.documents(file_path) do
#         {:ok, response} ->
#           # Handle the successful response
#           IO.puts("Document processed successfully: #{response}")

#         {:error, %Jason.DecodeError{data: data}} ->
#           file = "library/files/#{file_name}.epub"
#           path = Path.dirname(file)
#           case File.write(path, data) do
#             :ok ->
#               IO.puts("Data written successfully to #{file}")
#             {:error, reason} ->
#               IO.puts("Error writing file: #{reason}")
#           end
#         _ ->
#           {:error}
#       end
#     _ ->
#       {:error}
#   end
# end

# case Telegram.get_file(file_id) do
#   {:ok, %{"file_path" => file_path}} ->
#     IO.inspect(file_path)
#     response = Library.TelegramAPI.documents(file_path)
#     |> IO.inspect()
#     case response do
#       {:ok, output} ->
#         # Handle the successful response
#         IO.puts("Document processed successfully: #{output}")
#         case output do
#       {:ok, %Jason.DecodeError{data: data}} ->
#         # Handle JSON decode error specifically
#         file = "library/files/#{file_name}.epub"
#         path = Path.dirname(file)
#         case File.write(path, data) do
#           {:ok, _} ->
#             IO.puts("Data written successfully to #{file_path}")
#           {:error, reason} ->
#             IO.puts("Error writing file: #{reason}")
#         end
#         {:ok, _result} ->
#           # Handle successful case here
#           IO.puts("Successful handling of the document.")
#         end

#       {:error, _reason} ->
#         # Handle other errors
#         IO.puts("An error occurred.")
#     end

#   {:error, _reason} ->
#     # Handle error from Telegram.get_file
#     IO.puts("Error getting file from Telegram.")
# end

# case  do
#   {:ok, %{"file_path" => file_path}} ->
#     IO.inspect(file_path)
#     path = "#{@api_url}/file/bot#{@token}/#{file_path}"
#     HTTPoison.get(path)
#     |> IO.inspect()
#     |>
#     case  do
#       {:ok, %HTTPoison.Response{body: data}} ->
#         file_name = "Alices Adventures in Wonderland.epub"
#         local_file_path = Path.join(["lib", "library", "files", file_name])
#         write_file(local_file_path, data)

#       end

# end
# end
# def fetch_and_save_file(file_id) do
#   # Construct the file URL
#   file_path = "#{@api_url}/file/bot#{@token}/#{file_id}"

#   # Fetch the file
#   case HTTPoison.get(file_path) do
#     {:ok, %HTTPoison.Response{status_code: 200, body: data}} ->
#       # Construct a valid local file path (file_id might need to be sanitized or processed)
#       local_file_path = Path.join(["lib", "library", "files", file_id])

#       # Write the binary data to a file
#       write_file(local_file_path, data)
#     {:ok, %HTTPoison.Response{status_code: code}} ->
#       IO.puts("Failed to download file. HTTP Status Code: #{code}")
#     {:error, %HTTPoison.Error{reason: reason}} ->
#       IO.puts("Error fetching file: #{inspect(reason)}")
#   end

# def process_update(%{"message" => %{"chat" => %{"first_name" => first_name,"id" => chat_id,},
# "document" => %{"file_id" => file_id,"file_name" => file_name,"file_size" => file_size,
# "file_unique_id" => file_unique_id,"mime_type" =>"application/epub+zip"}}}
# ) do
#   case Telegram.get_file(file_id) do
#     {:ok, %{"file_path" => file_path}} ->
#       case Library.TelegramAPI.documents(file_path) do

#       {:ok, {:error, %Jason.DecodeError{data: data}}}  ->
#                file = "library/files/#{file_name}.epub"
#                path = Path.dirname(file_path)
#                   case File.write(path, data) do
#                         {:ok, _} ->
#                            IO.puts("Data written successfully to #{file_path}")

#                         {:error, reason} ->
#                            IO.puts("Error writing file: #{reason}")
#                    end
#       _-> {:error}

#     end
#     _-> {:error}
#   end
# end








  # def process_update(%{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} = update) do
  #   IO.inspect(update)
  # end

  # %{
  #   "callback_query" => %{
  #     "data" => "chapter05",
  #     "from" => %{
  #       "first_name" => first_name,
  #       "id" => chat_id,
  #       "last_name" => last_name,
  #       "username" => username
  #     },
  #       "reply_markup" => %{
  #         "inline_keyboard" => [

  #         ]
  #       },
  #       "text" => "Here are the list of Chapters, please select one:"
  #     }
  #   }







# %{
#   "message" => %{
#     "chat" => %{
#       "first_name" => first_name,
#       "id" => chat_id,
#       "last_name" => last_name,
#       "username" => username
#     },
#     "date" => 1711005085,
#     "message_id" => 1480,
#     "text" => text
#   }
# }



# %{
#   "callback_query" => %{
#     "data" => "chapter05",
#     "from" => %{
#       "first_name" => first_name,
#       "id" => chat_id,
#       "last_name" => last_name,
#       "username" => username
#     },
#     "message" => %{
#       "chat" => %{
#         "first_name" => firstname,
#         "id" => 977236716,
#         "last_name" => last_name,
#         "username" => username
#       }
#       },
#       "reply_markup" => %{
#         "inline_keyboard" => [
#           [%{"callback_data" => "titlepage", "text" => "titlepage"}],
#           [%{"callback_data" => "chapter06", "text" => "chapter06"}],
#           [%{"callback_data" => "chapter01", "text" => "chapter01"}],
#           [%{"callback_data" => "chapter07", "text" => "chapter07"}],
#           [%{"callback_data" => "chapter04", "text" => "chapter04"}],
#           [%{"callback_data" => "chapter10", "text" => "chapter10"}],
#           [%{"callback_data" => "chapter02", "text" => "chapter02"}],
#           [%{"callback_data" => "chapter08", "text" => "chapter08"}],
#           [%{"callback_data" => "titlepage1", "text" => "titlepage1"}],
#           [%{"callback_data" => "chapter03", "text" => "chapter03"}],
#           [%{"callback_data" => "chapter09", "text" => "chapter09"}],
#           [%{"callback_data" => "chapter12", "text" => "chapter12"}],
#           [%{"callback_data" => "chapter11", "text" => "chapter11"}],
#           [%{"callback_data" => "chapter05", "text" => "chapter05"}],
#           [%{"callback_data" => "titlepage", "text" => "titlepage"}],
#           [%{"callback_data" => "chapter06", "text" => "chapter06"}],
#           [%{"callback_data" => "chapter01", "text" => "chapter01"}],
#           [%{"callback_data" => "chapter07", "text" => "chapter07"}],
#           [%{"callback_data" => "chapter04", "text" => "chapter04"}],
#           [%{"callback_data" => "chapter10", "text" => "chapter10"}],
#           [%{"callback_data" => "chapter02", "text" => "chapter02"}],
#           [%{"callback_data" => "chapter08", "text" => "chapter08"}],
#           [%{"callback_data" => "titlepage1", "text" => "titlepage1"}],
#           [%{"callback_data" => "chapter03", "text" => "chapter03"}],
#           [%{"callback_data" => "chapter09", "text" => "chapter09"}],
#           [%{"callback_data" => "chapter12", "text" => "chapter12"}],
#           [%{"callback_data" => "chapter11", "text" => "chapter11"}],
#           [%{"callback_data" => "chapter05", "text" => "chapter05"}],
#           [%{"callback_data" => "cover", "text" => "cover"}],
#           [%{"callback_data" => "The_Idiot", "text" => "The_Idiot"}],
#           [%{"callback_data" => "toc", "text" => "toc"}]
#         ]
#       },
#       "text" => "Here are the list of Chapters, please select one:"
#     }
#   }
# }
# iex(1)>
