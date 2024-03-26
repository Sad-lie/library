# def on_files(file_paths) when is_list(file_paths) do
#   Enum.with_index(file_paths, 1)
#   |> Enum.map(fn {file_path, _index} ->
#     chapter_number = extract_chapter_number(file_path)

#     case File.read(file_path) do
#       {:ok, content} ->
#         processed_content =
#           content
#           |> filter_para()  # Assuming this function filters paragraphs
#           #|> nolist()       # Assuming this function removes lists
#           #|> maper()        #
#           |> IO.inspect()
#         # Generate a chapter title using the extracted chapter number
#         # title = "Chapter #{chapter_number}"
#         # IO.puts("Preparing to insert: #{title}")  # Debug: Check title before insert

#         # changeset =
#         #   %Library.Schema.Book{}
#         #   |> Ecto.Changeset.change(%{data: processed_content, name: title})

#         # case Library.Repo.insert(changeset) do
#         #   {:ok, _record} -> IO.puts("Record inserted successfully: #{title}")
#         #   {:error, changeset} ->
#         #     IO.puts("Failed to insert: #{title}")
#         #     IO.inspect(changeset.errors)  # More detailed error logging
#         # end

#       {:error, reason} ->
#         IO.puts("Failed to read #{file_path}: #{reason}")
#     end
#   end)
# end

# def extract_chapter_number(file_path) do
#   # Extracts numbers from the filename, assuming a format like "chapter1.xhtml"
#   # This is a simple regex to find numbers; adjust the pattern as necessary for your filenames.
#   case Regex.run(~r/\d+/, file_path) do
#     [number | _] -> number
#     _ -> "Unknown" # Fallback if no number is found
#   end
# end

# def on_files(file_paths) when is_list(file_paths) do
#   Enum.map(file_paths, fn file_path ->
#     case File.read(file_path) do
#       {:ok, content} ->
#         processed_content =
#           content
#           |> filter_para()
#           |> nolist()
#           |> maper()

#         title =
#           filter_meta(content)
#           |> unlist()
#           |> clean_title()

#         changeset =
#           %Library.Schema.Book{}
#           |> Ecto.Changeset.change(%{data: processed_content, name: title})

#         case Library.Repo.insert(changeset) do
#           {:ok, _record} -> IO.puts("Record inserted successfully.")
#           {:error, changeset} -> IO.inspect(changeset.errors)
#         end

#       {:error, reason} ->
#         IO.puts("Failed to read #{file_path}: #{reason}")
#     end
#   end)
# end
# def tuple({:ok ,y}), do: y
#   def file(list) do
#     Enum.map(list,fn x -> File.read(x)|> tuple() |> Floki.parse_document() end)
#   end
# def insert(paragraphs) do
#   Enum.each(paragraphs, fn %{parse: parse, paragraph: paragraph} ->
#     changeset = Library.Contents.changeset(%Library.Contents{}, %{
#       parse: parse,
#       paragraph: paragraph,
#       timestamp: NaiveDateTime.utc_now()  # Set the timestamp as needed
#       # Add other fields as necessary
#     })

#     case Library.Repo.insert(changeset) do
#       {:ok, _content} ->
#         IO.puts("Paragraph inserted successfully")
#       {:error, changeset} ->
#         IO.inspect(changeset.errors, label: "Error inserting paragraph")
#     end
#   end)
# end

# my_single_map = %{parse: "paragraph"}

# %Library.Content{}
# |> Ecto.Changeset.change(my_single_map)
# |> Library.Repo.insert()

# def insert(paragraphs) when is_map(paragraphs) do
#   #Enum.map(paragraphs, fn {index, paragraph} ->
#     # Assuming you want to insert the paragraphs even if they're just an index and a string
#     changeset = Library.Contents.changeset(%Library.Contents{}, %{
#       parse: nil,  # or any default value
#       paragraph: paragraphs,
#       timestamp: NaiveDateTime.utc_now()  # Set the timestamp as needed
#       # Add other fields as necessary
#     })

#     case Library.Repo.insert(changeset) do
#       {:ok, _content} ->
#         IO.puts("Paragraph inserted successfully")
#       {:error, changeset} ->
#         IO.inspect(changeset.errors, label: "Error inserting paragraph")
#     end
# end)
# end

# Fallback for other data types

# def process_files(contents) do
#   Enum.each(contents, &process_content/1)
# end

# defp process_content(content) do
#   IO.puts(String.slice(content, 0, 100))
#    def process(html) do
#      Enum.map(html, &extract_p/1)
#    end

#    defp extract_p({"p", _, content}) do
#      Enum.map(content, &extract_text/1) |> Enum.join(" ")
#    end
#    defp extract_p(_), do: nil

#    defp extract_text({_, _, c}) when is_list(c), do: Enum.map(c, &extract_text/1) |> Enum.join(" ")
#    defp extract_text(text) when is_binary(text), do: text
#    def titler(html) do
#      case html do
#        [{"title", _, [title_text]}] -> title_text
#        _ -> nil
#      end
#    end

# end
# def prog(x) ,do: x |> tuple() |> cup() |> tup() |> cup() |> tup()

# def tuple({:ok ,y}), do: y

# def tup({x,y,z}) ,do: z

# def cup([x,y]), do: y

# def filter_xhtml(xhtml) do
#   {:ok, parsed_html} = Floki.parse_document(xhtml)
#   p_tags = Floki.find(parsed_html, "p")
#   Enum.map(p_tags, &Floki.raw_html/1)
#   # Parse the XHTML content
# end
# def on_files(file_paths) when is_list(file_paths) do
#   Enum.map(file_paths, fn file_path ->
#     case File.read(file_path) do
#       {:ok, content} ->
#         x = filter_xhtml(content) |> IO.inspect()  |> nolist()  |> IO.inspect() |> maper()
#         %Library.Test{}
#         |> Ecto.Changeset.change(x)
#         |> Library.Repo.insert()

#       {:error, reason} ->
#         IO.puts("Failed to read #{file_path}: #{reason}")
#     end
#   end)
#   end




  # def start_menu do
  #   #  "Register", "add user to database",
  #   #  "Upload a book",
  #   #  "library"
  # end

  # def action_menu do
  #   #  "upload epub" |> "Uploaded succesfuly"  |> "Set intrvael " |> "getting the parse messeage"
  # end

  # def library_menu do
  #   #  "list"
  # end

  # def book_menu do
  #   # "select chapter"
  #   #  "select intravel"
  #   #  "start / pause"
  # end

 # def option_maker(input), do: [[%{text: input, callback_data: input}]]

  # def gogo do
  #   send_message("Choose an option:", @chat_id, %{
  #     reply_markup: %{
  #       inline_keyboard: [
  #         [%{text: "Option 1", callback_data: "option_1"}],
  #         [%{text: "Option 2", callback_data: "option_2"}],
  #         [%{text: "Option 3", callback_data: "option_3"}]
  #       ]
  #     }
  #   })
  # end
  # def keyboard(list_of_keyboard, text_option, chat_id) do
  #   keyboard_markup = %{one_time_keyboard: true, keyboard: list_of_keyboard}

  #   Telegram.Api.request(@token, "sendMessage",
  #     chat_id: chat_id,
  #     text: "#{text_option}",
  #     reply_markup: {:json, keyboard_markup}
  #   )
  # end

  # def istart do
  #   x = [["one", "two", "three"], ["one", "two", "three"], ["one", "two", "three"]]
  #   keyboard(x, "choose one", @chat_id)
  # end

  # def button(list_of_options, text_input, chat_id) do
  #   buttons = Enum.map(list_of_options, &option_maker/1)
  #   keyboard_markup = %{inline_keyboard: buttons}

  #   Telegram.Api.request(@token, "sendMessage",
  #     chat_id: chat_id,
  #     text: text_input,
  #     reply_markup: Jason.encode!(keyboard_markup)
  #   )
  # end


# def button(list_of_options,text_input,chat_id) do
#   buttons = Enum.map(list_of_options ,&option_maker/1)
#   keyboard_markup = %{
#     inline_keyboard: buttons
#   }
#   Telegram.Api.request(@token, "sendMessage", chat_id: chat_id, text: "#{text_input}", reply_markup: keyboard_markup)
# end
# def option_maker(input) ,do: [%{text: "#{input}", callback_data: "#{input}"}]

# send_message("Click here to visit Google", @chat_id, %{
#   reply_markup: %{
#     inline_keyboard: [
#       [
#         %{
#           text: "Visit Google",
#           url: "https://www.google.com"
#         }
#       ]
#     ]
#   }
# })
# {:ok, book_data} ->
#   # Process book data
#   Enum.each(book_data, fn {key, value} ->
#     Process.sleep(interval)
#     IO.puts("Key: #{key}, Value: #{value}")
#     text = value
#     Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)
#   end)
# {:error, reason} ->
#     sendMessage("An error occurred: #{inspect(reason)}", @chat_id)

# map = Library.Books.get_book_data_by_name(book_name)
# Enum.each(map, fn {key, value} ->
#  Process.sleep(interval)
#  IO.puts("Key: #{key}, Value: #{value}")
#  text = value
#  Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)
# end)
# end
# def list_of_books_option_make()do
#   reply_markup = %{
#   }
#   send_message(text , @chat_id,)

# end
# def handle_update(%{"message" => %{"document" => document}} = _update) do
#   # Extract the MIME type and file ID from the document
#   mime_type = document["mime_type"]
#   file_id = document["file_id"]

#   # Check if the MIME type is for an EPUB file
#   if mime_type == "application/epub+zip" do
#     # Use the `getFile` method to get the file path
#     {:ok, file_path} = Telegram.Api.request(@token, "getFile", file_id: file_id)

#     # Construct the download URL and download the file
#     _download_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
#     # Add your code to download the file using the download_url

#     # Proceed with your logic for handling EPUB files
#     # ...
#   else
#     # Handle other file types or send a message to the user
#     # ...

#   end
#   # Set your bot token and your server's URL
# end

# def text_sender do
#   x = %{1 => "one",2 =>"two",3 => "three"}
#   Enum.map()
# end
# def iterate_through_map(interval \\ 1000) do

#   map = sender()
#   case System.read_timer(5000) do
#     {:ok, _} ->
#       for {key, value} <- map do
#         Process.sleep(interval)
#         IO.puts("Key: #{key}, Value: #{value}")
#         text = value
#         Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)

#       end
#     {:error, :timeout} ->
#       IO.puts("No input received. Starting iteration immediately.")
#       for {key, value} <- map do
#         Process.sleep(interval)
#         IO.puts("Key: #{key}, Value: #{value}")
#         text = value
#         Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)

#       end
#   end
# end

# def buttons do
#   # Define your inline keyboard buttons
#      buttons = [
#         [%{text: "Option 1", callback_data: "option_1"}],
#         [%{text: "Option 2", callback_data: "option_2"}]
#       ]

# # Create the inline keyboard markup
#       keyboard_markup = %{
#         inline_keyboard: buttons
#       }

# # Send a message with the inline keyboard
#       Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: "Choose an option:", reply_markup: keyboard_markup)
# end
#   def keyboard() do
#     keyboard = [
#      ["A0", "A1"],
#      ["B0", "B1", "B2"]
#     ]
#    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}
#    Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: "Here a keyboard!", reply_markup: {:json, keyboard_markup})
# end

# def sender do
#   _text = %{
#      12 => "  'Pepper, mostly,' said the cook.", 18 => "  'You're a very poor speaker,' said the King.",
#   11 => "  'It began with the tea,' the Hatter replied.", 19 => "  'Not yet, not yet!' the Rabbit hastily interrupted.  'There's\na great deal to come before that!'",
#   10 => "  'I'd rather finish my tea,' said the Hatter, with an anxious\nlook at the Queen, who was reading the list of singers.",
#   9 => "  'I'm a poor man,' the Hatter went on, 'and most things\ntwinkled after that--only the March Hare said--'",
#   8 => "  'I didn't!' the March Hare interrupted in a great hurry.",
#   7 => "  'Write that down,' the King said to the jury, and the jury\neagerly wrote down all three dates on their slates, and then\nadded them up, and reduced the answer to shillings and pence.",
#   5 => "  The first witness was the Hatter.  He came in with a teacup in\none hand and a piece of bread-and-butter in the other.  'I beg\npardon, your Majesty,' he began, 'for bringing these in:  but I\nhadn't quite finished my tea when I was sent for.'",
#   6 => "  'Call the first witness,' said the King; and the White Rabbit\nblew three blasts on the trumpet, and called out, 'First\nwitness!'",
#   4 => "  'You may go,' said the King, and the Hatter hurriedly left the\ncourt, without even waiting to put his shoes on.",
#   2 => "  Alice had never been in a court of justice before, but she had\nread about them in books, and she was quite pleased to find that\nshe knew the name of nearly everything there.  'That's the\njudge,' she said to herself, 'because of his great wig.'",
#   3 => "  'Stupid things!' Alice began in a loud, indignant voice, but\nshe stopped hastily, for the White Rabbit cried out, 'Silence in\nthe court!' and the King put on his spectacles and looked\nanxiously round, to make out who was talking.",
#   1 => "\n  The King and Queen of Hearts were seated on their throne when\nthey arrived, with a great crowd assembled about them--all sorts\nof little birds and beasts, as well as the whole pack of cards:\nthe Knave was standing before them, in chains,
#         with a soldier on\neach side to guard him; and near the King was the White Rabbit,\nwith a trumpet in one hand, and a scroll of parchment in the\nother.  In the very middle of the court was a table, with a large\ndish of tarts upon it:  they looked so good, that it made Alice\n
#         quite hungry to look at them--'I wish they'd get the trial done,'\nshe thought, 'and hand round the refreshments!'  But there seemed\nto be no chance of this, so she began looking at everything about\nher, to pass away the time.",
#   13 => "  Alice could see, as well as if she were looking over their\nshoulders, that all the jurors were writing down 'stupid things!'\non their slates, and she could even make out that one of them\ndidn't know how to spell 'stupid,' and that he had to ask his\nneighbour to tell him.  'A nice muddle their slates'll be in\nbefore the trial's over!' thought Alice.",
#   14 => "  The judge, by the way, was the King; and as he wore his crown\nover the wig, (look at the frontispiece if you want to see how he\ndid it,) he did not look at all comfortable, and it was certainly\nnot becoming.",
#   15 => "  'Come, that finished the guinea-pigs!' thought Alice.  'Now we\nshall get on better.'",
#   16 => "  'I can't go no lower,' said the Hatter:  'I'm on the floor, as\nit is.'",
#   17 => "  The Hatter looked at the March Hare, who had followed him into\nthe court, arm-in-arm with the Dormouse.  'Fourteenth of March, I\nthink it was,' he said."}

#  # Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)

#   end

# def get_file_info(file_id) do
#   case fetch_file_path(file_id) do
#     {:ok, %{"file_path" => file_path}} ->
#       case fetch_file_content(file_path) do
#         {:ok, file} ->
#           # Process the file information (e.g., log, analyze, etc.)
#           IO.inspect(file)
#         {:error, reason} ->
#           IO.puts("Error fetching file content: #{reason}")
#       end
#     {:error, reason} ->
#       IO.puts("Error fetching file path: #{reason}")
#   end
# end

# defp fetch_file_path(file_id) do
#   url = "#{@base_url}#{@token}/getFile"
#   case HTTPoison.get(url, params: %{"file_id" => file_id}) do
#     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#       {:ok, Jason.decode(body)}
#     {:ok, %HTTPoison.Response{status_code: code}} ->
#       {:error, "HTTP error with status code: #{code}"}
#     {:error, reason} ->
#       {:error, "HTTP request failed: #{inspect(reason)}"}
#   end
# end

# defp fetch_file_content(file_path) do
#   full_url = "#{@base_url}#{@token}/#{file_path}"
#   case HTTPoison.get(full_url) do
#     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#       {:ok, body}
#     {:ok, %HTTPoison.Response{status_code: code}} ->
#       {:error, "HTTP error with status code: #{code}"}
#     {:error, reason} ->
#       {:error, "HTTP request failed: #{inspect(reason)}"}
#   end
# end
# defp get_file_path(file_id) do
#   {:ok, response} = MyTelegramClient.get_file(file_id)
#   file_path = response["result"]["file_path"]
#   file_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
#   download_file(file_url)
# end

# defp download_file(file_url) do
#   {:ok, %HTTPoison.Response{body: file_contents}} = HTTPoison.get(file_url)
#   File.write("path/to/save/yourfile.epub", file_contents)
#   # Now you can use the EPUB file as needed
# # end
# defp get_file_path(file_id) do
#   bot_token = System.get_env("TELEGRAM_BOT_TOKEN")
#   url = "https://api.telegram.org/bot#{bot_token}/getFile?file_id=#{file_id}"

#   case HTTPoison.get(url) do
#     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#       response = Jason.decode!(body)
#       if response["ok"] do
#         file_path = response["result"]["file_path"]
#         {:ok, "https://api.telegram.org/file/bot#{bot_token}/#{file_path}"}
#       else
#         {:error, :failed_to_get_file_path}
#       end
#     {:error, _reason} ->
#       {:error, :request_failed}
#   end
# end

# defp download_file(file_url) do
#   case HTTPoison.get(file_url) do
#     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#       {:ok, body}
#     {:error, _reason} ->
#       {:error, :download_failed}
#   end
# end

# defp handle_file_contents(contents, file_name) do
#   File.write("path/#{file_name}", contents)
# end
#  def process_epub_file(document, chat_id) do
#   # Assuming `document` is always a map with at least a "file_id"
#   file_id = document["file_id"]
#   i =  Telegram.get_file_path(file_id)
#   # Fetch the file path using the file_id.
#   Logger.info("i")
#   # This requires the implementation of `Telegram.get_file_path/1` which should return {:ok, file_path} or an error tuple
#   case i do

#     {:ok, file_path} ->
#       file_url = "https://api.telegram.org/file/bot#{@token}/" <> file_path
#       case HTTPoison.get(file_url) do
#         {:ok, %HTTPoison.Response{status_code: 200, body: file_content}} ->
#           # Assuming `LibraryWeb.LibraryController.unzip_epub/1` processes the file content
#           LibraryWeb.LibraryController.unzip_epub(file_content)
#           send_file_received_message("Received and processed your EPUB file!", chat_id)
#           {:error, %HTTPoison.Error{id: _id, reason: reason}} ->
#             Logger.error("Failed to download the EPUB file due to: #{inspect(reason)}")
#             send_file_received_message("Failed to download the EPUB file.", chat_id)
#             {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} when status_code != 200 ->
#               Logger.error("Received HTTP status #{status_code} when trying to download the EPUB file.")
#               send_file_received_message("Failed to download the EPUB file due to HTTP status #{status_code}.", chat_id)

#         {:error, _reason} ->
#           send_file_received_message("Failed", chat_id)
#       end

#     {:error, reason} ->
#       Telegram.sendMessage("Failed to retrieve file path.#{reason}", chat_id)
#   end
# end

# def handle_message(%{"document" => document} = message) do
#   file_id = document["file_id"]
#   file_name = document["file_name"]

#   # Log or use the file name as needed
#   IO.puts("Received file: #{file_name}")

#   # Proceed to get the file path using the file_id
#   file_path_response = get_file_path(file_id)

#   case file_path_response do
#     {:ok, file_path} ->
#       # Download and use the file
#       IO.puts("File path received: #{file_path}")
#       {:ok, file_contents} = download_file(file_path)

#       # Assuming you have a function to handle the file contents
#       handle_file_contents(file_contents,file_path)

#     {:error, _reason} ->
#       IO.puts("Failed to get file path")
#   end
# end
# def process_message(%{"document" => %{"mime_type" => "application/epub+zip"} = document,"chat" => %{"id" => chat_id}}) do
#     process_epub_file(document, chat_id)
# end

#  def process_message(%{"document" => %{"mime_type" => "application/epub+zip"} = document,"chat" => %{"id" => chat_id}}) do
#     file_id = document["file_id"]
#     get_file_path(file_id)
#   end
# def process_message(%{"document" => %{"mime_type" => "application/epub+zip"} = document,"chat" => %{"id" => chat_id}}) do
#   file_id = document["file_id"]
#   file_name = document["file_name"]

#   # Log or use the file name as needed
#   IO.puts("Received file: #{file_name}")

#   # Proceed to get the file path using the file_id
#   file_path_response = get_file_path(file_id)

#   case file_path_response do
#     {:ok, file_path} ->
#       # Download and use the file
#       IO.puts("File path received: #{file_path}")
#       {:ok, file_contents} = download_file(file_path)

#       # Assuming you have a function to handle the file contents
#       handle_file_contents(file_contents,file_path)

#     {:error, _reason} ->
#       IO.puts("Failed to get file path")
#   end
# end
