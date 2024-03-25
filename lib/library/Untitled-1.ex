
  # def process_start("/start", chat_id, first_name, last_name, username) do
  #   {:ok, decimal}  =  Library.Users.get_user_telegram_id_by_name(username)
  #   user_id = Decimal.to_integer(decimal)
  #   IO.inspect(user_id)

  #   case Library.Users.user_exists_by_telegram_id?(user_id) do
  #     false ->
  #       current_time = DateTime.utc_now() |> DateTime.to_string()
  #       collection_id = :rand.uniform(1000_000_000) |> Kernel.+(user_id)

  #       user_attrs = %{
  #         "telegram_id" => user_id,
  #         "name" => username,
  #         "first_name" => first_name,
  #         "last_name" => last_name,
  #         "timestamp" => current_time
  #       }

  #       IO.inspect(user_attrs)

  #       {:ok, user} = Library.Users.create_user(user_attrs)

  #       collection_attrs = %{"timestamp" => current_time, "user_id" => user.id}
  #       IO.inspect(collection_attrs)

  #       {:ok, collection} = Library.Collections.create_collection(collection_attrs)
  #       IO.inspect(collection)

  #       Telegram.sendMessage(
  #         "Welcome to the Library Bot. Your account has been created, with #{first_name} #{last_name}",
  #         chat_id
  #       )

  #     true ->
  #       Telegram.sendMessage(
  #         "Hey #{first_name} #{last_name} Welcome back to the Library Bot.",
  #         chat_id
  #       )
  #   end
  # end


#   %{"callback_query" => %{"data" => data, "message" => %{"chat" => %{"id" => chat_id}}}} =
#   updater
# # )
#   def process_callback_query(data, chat_id) do


#     case String.split(data) do
#       "/interval" <> interval_string ->
#         handle_callback_interval("/interval " <> interval_string, chat_id)

#       _ ->
#         response_message = "You selected: #{data}"
#         Telegram.sendMessage(response_message, chat_id)

#         try do
#           case Telegram.iterate_through_map(data) do
#             :ok ->
#               Telegram.iterate_through_map(data)

#             _ ->
#               Telegram.sendMessage("Nothing Left...", chat_id)
#           end
#         rescue
#           exception ->
#             Logger.error("Error processing update: #{inspect(exception)}")

#             error_response = handle_errors(exception)

#             error_message =
#               case error_response do
#                 {:error, :case_clause_error} -> "A case clause error occurred."
#                 {:error, :key_missing} -> "A required key is missing."
#                 {:error, :unknown_error} -> "An unexpected error occurred."
#               end

#             Telegram.sendMessage("An unexpected error occurred: #{error_message}", chat_id)
#         end
#       end
#   end

  # def process_intervel("/interval", chat_id) do
  #   list = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
  #   send_books_list(list, "Select the interval:", chat_id)

  # end

  # def handle_callback_data("/interval", chat_id) do
  #   list = ["5 Sec", "30 Sec", "60 Sec", "5 Mins", "30 Mins", "60 Mins", "2 Hrs", "4 Hrs"]
  #   send_books_list(list, "Select the interval:", chat_id)
  # end
  # def new do
  #   process_update(%{
  #     "message" => %{
  #       "chat" => %{
  #         "first_name" => "Wania",
  #         "id" => 977_236_716
  #       },
  #       "document" => %{
  #         "file_id" => "BQACAgUAAxkBAAIFrGX6fWnZ_UJ4hXx5uM0bvbYYKjfBAAKVCwACQ5HQVxaNimSepLuoNAQ",
  #         "file_name" => "Alices Adventures in Wonderland.epub",
  #         "file_size" => 885_898,
  #         "file_unique_id" => "AgADlQsAAkOR0Fc",
  #         "mime_type" => "application/epub+zip"
  #       }
  #     }
  #   })
  #   |> case do
  #     {:ok, %{"file_path" => file_path}} ->
  #       IO.inspect(file_path)
  #       path = "#{@api_url}/file/bot#{@token}/#{file_path}"

  #       case download_epub(path) do
  #         :ok ->
  #           IO.puts("File downloaded successfully")
  #           |> LibraryWeb.LibraryController.unzip_epub()

  #         {:error, reason} ->
  #           IO.puts("Error: #{reason}")
  #       end

  #     _ ->
  #       {:error}
  #   end
  # end

 # def process_update(%{"callback_query" => %{"data" => interval_string, "message" => %{"chat" => %{"id" => chat_id}}}}) do
  #   case Integer.chapter(interval_string) do
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
