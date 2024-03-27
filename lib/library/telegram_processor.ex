
defmodule Library.TelegramProcessor do

  alias LibraryWeb.MyFile
  alias Library.TelegramAPI
  alias LibraryWeb.TelegramController, as: Telegram

  require Logger
  alias Library.Repo
  alias Library.Schema.Book
  import Ecto.Query, warn: false
  alias HTTPoison

  @api_url "https://api.telegram.org"
  @chat_id 977_236_716
  @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
  @base_url "https://api.telegram.org/"
  def process_start(chat_id,first_name, last_name, username) do

    case  to_string(chat_id)|> Library.Users.user_exists() do
      true ->
        Telegram.sendMessage(
          "Hey #{first_name} #{last_name} Welcome back to the Library Bot.",
          chat_id
        )

      false->
        current_time = DateTime.utc_now() |> DateTime.to_string()
        collection_id = :rand.uniform(1000_000_000) |> Kernel.+(chat_id)

        user_attrs = %{
          "telegram_id" => to_string(chat_id),
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
        _-> Telegram.sendMessage(
          "HSomething went wrong with user registration",
          chat_id
        )

    end
  end

  def process_list(chat_id, first_name, last_name, username) do
    IO.inspect(chat_id)
    chat_id_string = to_string(chat_id)

    case Library.Books.list_book(chat_id_string) do
      false ->
        Telegram.sendMessage("#{first_name} #{last_name} You haven't added any books yet. Please upload a book first.", chat_id)
      true ->
        query = from(b in Book, where: b.telegram_id == ^chat_id_string, select: %{name: b.name})
        books = Repo.all(query)

        list = Enum.map(books, fn book -> book.name end)
        send_book_options(list, "Here are the list of books, please select one:", chat_id, "/list")
    end
  end
  def process_chapter(chat_id, first_name, last_name, username) do
    IO.inspect(chat_id)
    chat_id_string = to_string(chat_id)

    case Library.Contents.list_content(chat_id_string) do
      [] ->
        Telegram.sendMessage("#{first_name} #{last_name} There are no chapters available.", chat_id)
      chapters ->
        content_list = Enum.map(chapters, fn chapter -> chapter.chapter end)
        send_chapter_options(content_list, "Here are the list of Chapters, please select one:", chat_id, "/chapter")
    end
  end

  def process_intervel(chat_id,first_name, last_name, username) do
    interval_options = ["5", "30", "60", "300", "1800", "3600", "7200", "14400"]

    interval_labels = ["5 Sec","30 Sec","1 Mins","5 Mins","30 Mins","1 Hrs"]

    send_interval_options(interval_options, interval_labels, "Select the interval:", chat_id)
  end

  def process_documents(first_name, last_name, username, chat_id, file_id, file_name) do
    case Library.Books.get_book_by_name(file_name) do
      false ->
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
                user_id = to_string(chat_id)
                book_id = :rand.uniform(1000_000_000)

                # Convert the DateTime string to NaiveDateTime
                current_time_iso8601 = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()

                case NaiveDateTime.from_iso8601(current_time_iso8601) do
                  {:ok, naive_datetime} ->
                    # Use the NaiveDateTime in your changeset
                    changeset =
                      %Library.Schema.Book{}
                      |> Ecto.Changeset.change(%{
                        name: file_name,
                        telegram_id: user_id,
                        book_id: book_id
                      })
                      |> Ecto.Changeset.put_change(:timestamp, naive_datetime)

                    IO.inspect(changeset)

                    case Library.Repo.insert(changeset) do
                      {:ok, _record} ->
                        Telegram.sendMessage(
                          "#{first_name} #{last_name} inserted #{file_name} successfully.",
                          chat_id
                        )

                      {:error, changeset} ->
                        IO.inspect(changeset.errors)
                    end

                  {:error, reason} ->
                    # Handle the error case
                    IO.puts("Error converting timestamp: #{reason}")
                end

                LibraryWeb.LibraryController.unzip_epub(
                  "/home/liar/elixir/projects/library/#{local_file_path}",
                  book_id,
                  user_id
                )
                Telegram.sendMessage("Book Gone through Unzip Successfully", chat_id)
                |> IO.inspect()

              {:error, %HTTPoison.Error{reason: :timeout}} ->
                Telegram.sendMessage("#{:timeout} and #{}Request timed out. Please try again later.", chat_id)

              {:error, error} ->
                IO.inspect(error, label: "Unexpected Error")
            end

          _ ->
            Telegram.sendMessage("Something Else went wrong", chat_id)
        end

      true ->
        Telegram.sendMessage("#{first_name} #{last_name} You have already added #{file_name}.", chat_id)

      _ ->
        Telegram.sendMessage("Something Else went wrong While adding the book", chat_id)
    end
  end

#   def process_documents(first_name,last_name, username, chat_id, file_id, file_name) do
#     case Library.Books.get_book_by_name(file_name) do

#     false ->
#     Telegram.get_file(file_id)
#     |> case do
#       {:ok, %{"file_path" => file_path}} ->
#         IO.inspect(file_path)
#         path = "#{@api_url}/file/bot#{@token}/#{file_path}"

#         HTTPoison.get(path)
#         |> IO.inspect()
#         |> case do
#           {:ok, %HTTPoison.Response{body: data}} ->
#             local_file_path = Path.join(["lib", "library", "files", file_name])
#             write_file(local_file_path, data)
#             user_id = to_string(chat_id)
#             book_id = :rand.uniform(1000_000_000)
#            # Convert the DateTime string to NaiveDateTime
#             current_time_iso8601 = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
#             case NaiveDateTime.from_iso8601(current_time_iso8601) do
#                 {:ok, naive_datetime} ->
#                   # Use the NaiveDateTime in your changeset

#                    changeset =
#                     %Library.Schema.Book{}
#                       |> Ecto.Changeset.change(%{name: file_name, telegram_id: user_id, book_id: book_id})
#                       |> Ecto.Changeset.put_change(:timestamp, naive_datetime)

#                     IO.inspect(changeset)

#                     case Library.Repo.insert(changeset) do
#                       {:ok, _record} ->
#                         Telegram.sendMessage("#{first_name} #{last_name} inserted #{file_name} successfully.", chat_id)

#                        {:error, changeset} ->
#                           IO.inspect(changeset.errors)
#                     end
#                 {:error, reason} ->
#             # Handle the error case
#                 IO.puts("Error converting timestamp: #{reason}")
#             end
#             LibraryWeb.LibraryController.unzip_epub("/home/liar/elixir/projects/library/#{local_file_path}",book_id, user_id)
#             |> IO.inspect()
#             # book_id = Library.Books.get_book_id(file_name)
#             # case Library.Books.get_book_by_name(file_name) do
#             #   true ->
#             #     # Book exists, get the book_id
#             #     [book_id] = Library.Books.get_book_id(file_name)
#             #     params = %{"telegram_id" => user_id, "book_id" => book_id}
#             #     Library.Contents.update_missing_parts(params)
#             #     Telegram.sendMessage("#{first_name} #{last_name} Chapters of #{file_name} is ready.", chat_id)
#             #   false ->
#             #     # Book doesn't exist, proceed with inserting a new book
#             #     # ... (existing code)
#             #     Telegram.sendMessage("An error occured while updateing book", chat_id)
#             # end
#             # IO.inspect(local_file_path)
#             # params = %{"telegram_id" => user_id, "book_id" => book_id }
#             # IO.inspect(params)
#             # Library.Contents.update_missing_parts(params)

#         end

#       {:error, %HTTPoison.Error{reason: :timeout}} ->
#         Telegram.sendMessage("Request timed out. Please try again later.", chat_id)

#       {:error, error} ->
#         IO.inspect(error, label: "Unexpected Error")
#         _-> Telegram.sendMessage("Something Else went wrong", chat_id)
#     end
#     |> LibraryWeb.LibraryController.unzip_epub()
#     true -> Telegram.sendMessage("#{first_name} #{last_name} You have already added #{file_name}.", chat_id)
#     _-> Telegram.sendMessage("Something Else went wrong While adding the book", chat_id)
#   end
# end

  #call backs

  def handle_callback_list(data,chat_id,first_name, last_name, username) do
    IO.inspect(data)
    # books = Library.Books.get_books_by_user_id(user_id)
    # list = Enum.map(books, fn book -> book["name"] end)
   # send_books_list(list, "Here are the list of books, please select one:", chat_id)
  end

  def handle_callback_chapter(data,chat_id,first_name, last_name, username) do
    IO.inspect(data)
    # list = Library.Contents.list_contents()
    # books_list = Enum.map(list, fn book -> "#{book.chapter}#{book.data["author"]}" end)
    # send_books_list(books_list, "Here are the list of Chapters, please select one:", chat_id)
  end

  def handle_callback_interval(data,chat_id,first_name, last_name, username) do
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

  def send_interval_options(options, labels, text_input, chat_id) do
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

  def send_book_options(list_of_books, text_input, chat_id, callback_data_prefix \\ "") do
    buttons = Enum.map(list_of_books, &option_maker(&1, callback_data_prefix))

    keyboard_markup = %{
      inline_keyboard: Enum.map(buttons, fn button -> [button] end)
    }

    Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
  end
  def send_chapter_options(list_of_books, text_input, chat_id, callback_data_prefix \\ "") do
    buttons = Enum.map(list_of_books, &option_maker(&1, callback_data_prefix))

    keyboard_markup = %{
      inline_keyboard: Enum.map(buttons, fn button -> [button] end)
    }

    Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
  end

  defp encode_button({option, label}) do
    %{text: label, callback_data: "/interval #{option}"}
  end

  def option_maker(book_name, callback_data_prefix) do
    %{text: book_name, callback_data: "#{callback_data_prefix} #{book_name}"}
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

  # funtions


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

end



  # def process_chapter(chat_id,first_name, last_name, username) do
  #   IO.inspect(chat_id)
  #       case chapter =  to_string(chat_id)|>   Library.Contents.list_content() |> IO.inspect() do
  #           false ->
  #               Telegram.sendMessage("#{first_name} #{last_name} There are no chapters available.",chat_id)
  #           true ->
  #            # books_list =
  #          #   Enum.map(list, fn book ->
  #           #"#{book.chapter}#{book.data["author"]}"
  #          # end)
  #             content_list = Enum.map(chapter, fn book -> "#{book.chapter}" end)
  #             send_chapter_options(content_list, "Here are the list of Chapters, please select one:", chat_id,"/chapter")
  #             error ->
  #                   Telegram.sendMessage("#{error} went wrong while retrieving chapter", chat_id)
  #         end
  # end

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
  # def send_books_list(list_of_books, text_input, chat_id, callback_data_prefix \\ "") do
  #   buttons = Enum.map(list_of_books, &option_maker(&1, callback_data_prefix))

  #   keyboard_markup = %{
  #     inline_keyboard: Enum.map(buttons, fn button -> [button] end)
  #   }

  #   Telegram.req(chat_id, text_input, Jason.encode!(keyboard_markup))
  # end
    # def option_maker(book_name) do
  #   %{text: book_name, callback_data: book_name}
  # end
