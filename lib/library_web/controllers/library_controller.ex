defmodule LibraryWeb.LibraryController do

  def start do
    unzip_epub("/home/liar/Downloads/epub/one/Alices Adventures in Wonderland.epub")
  end
    def unzip_epub(file_path) do
      case File.read(file_path) do
        {:ok, content} ->
          case :zip.unzip(content) do
            {:ok, ext_files} ->
                IO.puts("EPUB successfully unzipped!")
                ext_files
                 |> Enum.map(&to_string/1)
                 |> ext_xhtml()
                 |> Enum.map(&on_files/1)

                {:error, reason} ->
            {:error, "Failed to unzip EPUB: #{reason}"}
          end
      {:error, reason} ->
        {:error, "Error reading EPUB file: #{reason}"}
    end
    end
    def maper(text) do
      text
      |> String.split("\n\n")
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {paragraph, index}, acc ->
        Map.put(acc, index, paragraph)
      end)
    end

    def nolist(xhtml) do
      parsed_content = Floki.parse_document(xhtml)
      |> elem(1)  # Get the parsed HTML tree
      _text_content = Floki.text(parsed_content)

    end

    def filter_para(xhtml) do
      {:ok, parsed_html} = Floki.parse_document(xhtml)
      #IO.inspect(parsed_html, label: "Parsed HTML")
      p_tags = Floki.find(parsed_html, "p")
      #IO.inspect(p_tags, label: "P tags")
      Enum.map(p_tags, &Floki.raw_html/1)
    end
    def filter_meta(xhtml) do
      {:ok, parsed_html} = Floki.parse_document(xhtml)
      #IO.inspect(parsed_html, label: "Parsed HTML")
      p_tags = Floki.find(parsed_html, "title")
      #IO.inspect(p_tags, label: "P tags")
      Enum.map(p_tags, &Floki.raw_html/1)
    end
    def ext_xhtml(files) do
      Enum.filter(files, fn file -> String.contains?(file, ".xhtml")end)
    end

    def unlist([x]), do: x
    def nofile(file_path) do
      case File.read(file_path) do
        {:ok, content} ->
          _x = filter_meta(content) |> IO.inspect()  |> nolist() |> maper() |> insert()

        {:error, reason} ->
          IO.puts("Failed to read #{file_path}: #{reason}")
      end
    end
    def on_files(file_paths) when is_list(file_paths) do
      Enum.map(file_paths, fn file_path ->
        case File.read(file_path) do
          {:ok, content} ->
            processed_content = content
            |> filter_para()
            |> nolist()
            |> maper()
            title = filter_meta(content)
            |> unlist()
            |> clean_title()
            changeset = %Library.Test{}
            |> Ecto.Changeset.change(%{data: processed_content, string: title})

            case Library.Repo.insert(changeset) do
              {:ok, _record} -> IO.puts("Record inserted successfully.")
              {:error, changeset} -> IO.inspect(changeset.errors)
            end

          {:error, reason} ->
            IO.puts("Failed to read #{file_path}: #{reason}")
        end
      end)
    end
    def on_files(file_path) when is_binary(file_path) do
      on_files([file_path])
    end
    def action(content) do
      filter_para(content) |> IO.inspect()  |> nolist()  |> IO.inspect() |> maper()
    end
    def first([head | _tail] = _list) do
      action(head)
    end

    def first([]), do: :empty_list
    def insert(_unexpected_data) do
      IO.puts("Received unexpected data format, skipping insert.")
    end
    def clean_title(html_string) when is_binary(html_string) do
      case Floki.find(html_string, "title") do
        title_element -> Floki.text(title_element)
        _ -> "No title found"
      end
    end
  end

  defmodule LibraryWeb.LibraryController.Unuser do


      @chat_id 977236716
      @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
      @base_url "https://api.telegram.org/"

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
      def iterate_through_map(interval \\ 5000) do
        map = sender() # Make sure this gets your map as expected.

        Enum.each(map, fn {key, value} ->
          # Sleep for the specified interval at the start of each iteration
          Process.sleep(interval)

          IO.puts("Key: #{key}, Value: #{value}")
          text = value

          # Assuming you have a function to send a message via Telegram.
          # Ensure @token and @chat_id are correctly set.
          Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)
        end)
      end


      # IO.puts("Enter a key (integer):")
      # user_input = IO.gets("") |> String.trim() |> String.to_integer()

      #   value = Map.get(map, user_input)


      #   case value do
      #       nil -> IO.puts("Key not found")
      #       _ -> IO.puts("Value: #{value}")
      #   end

      def sender do

      _text = %{
         12 => "  'Pepper, mostly,' said the cook.", 18 => "  'You're a very poor speaker,' said the King.",
      11 => "  'It began with the tea,' the Hatter replied.", 19 => "  'Not yet, not yet!' the Rabbit hastily interrupted.  'There's\na great deal to come before that!'",
      10 => "  'I'd rather finish my tea,' said the Hatter, with an anxious\nlook at the Queen, who was reading the list of singers.",
      9 => "  'I'm a poor man,' the Hatter went on, 'and most things\ntwinkled after that--only the March Hare said--'",
      8 => "  'I didn't!' the March Hare interrupted in a great hurry.",
      7 => "  'Write that down,' the King said to the jury, and the jury\neagerly wrote down all three dates on their slates, and then\nadded them up, and reduced the answer to shillings and pence.",
      5 => "  The first witness was the Hatter.  He came in with a teacup in\none hand and a piece of bread-and-butter in the other.  'I beg\npardon, your Majesty,' he began, 'for bringing these in:  but I\nhadn't quite finished my tea when I was sent for.'",
      6 => "  'Call the first witness,' said the King; and the White Rabbit\nblew three blasts on the trumpet, and called out, 'First\nwitness!'",
      4 => "  'You may go,' said the King, and the Hatter hurriedly left the\ncourt, without even waiting to put his shoes on.",
      2 => "  Alice had never been in a court of justice before, but she had\nread about them in books, and she was quite pleased to find that\nshe knew the name of nearly everything there.  'That's the\njudge,' she said to herself, 'because of his great wig.'",
      3 => "  'Stupid things!' Alice began in a loud, indignant voice, but\nshe stopped hastily, for the White Rabbit cried out, 'Silence in\nthe court!' and the King put on his spectacles and looked\nanxiously round, to make out who was talking.",
      1 => "\n  The King and Queen of Hearts were seated on their throne when\nthey arrived, with a great crowd assembled about them--all sorts\nof little birds and beasts, as well as the whole pack of cards:\nthe Knave was standing before them, in chains,
            with a soldier on\neach side to guard him; and near the King was the White Rabbit,\nwith a trumpet in one hand, and a scroll of parchment in the\nother.  In the very middle of the court was a table, with a large\ndish of tarts upon it:  they looked so good, that it made Alice\n
            quite hungry to look at them--'I wish they'd get the trial done,'\nshe thought, 'and hand round the refreshments!'  But there seemed\nto be no chance of this, so she began looking at everything about\nher, to pass away the time.",
      13 => "  Alice could see, as well as if she were looking over their\nshoulders, that all the jurors were writing down 'stupid things!'\non their slates, and she could even make out that one of them\ndidn't know how to spell 'stupid,' and that he had to ask his\nneighbour to tell him.  'A nice muddle their slates'll be in\nbefore the trial's over!' thought Alice.",
      14 => "  The judge, by the way, was the King; and as he wore his crown\nover the wig, (look at the frontispiece if you want to see how he\ndid it,) he did not look at all comfortable, and it was certainly\nnot becoming.",
      15 => "  'Come, that finished the guinea-pigs!' thought Alice.  'Now we\nshall get on better.'",
      16 => "  'I can't go no lower,' said the Hatter:  'I'm on the floor, as\nit is.'",
      17 => "  The Hatter looked at the March Hare, who had followed him into\nthe court, arm-in-arm with the Dormouse.  'Fourteenth of March, I\nthink it was,' he said."}

     # Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)

    end
    def handle_update(%{"message" => %{"document" => document}} = _update) do
      # Extract the MIME type and file ID from the document
      mime_type = document["mime_type"]
      file_id = document["file_id"]

      # Check if the MIME type is for an EPUB file
      if mime_type == "application/epub+zip" do
        # Use the `getFile` method to get the file path
        {:ok, file_path} = Telegram.Api.request(@token, "getFile", file_id: file_id)

        # Construct the download URL and download the file
        _download_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
        # Add your code to download the file using the download_url

        # Proceed with your logic for handling EPUB files
        # ...
      else
        # Handle other file types or send a message to the user
        # ...

      end
      # Set your bot token and your server's URL
    end
      def undo do

# Use the `setWebhook` method to tell Telegram to send updates to your URL
        {:ok, response} = Telegram.Api.request(@token, "setWebhook", url: @base_url)
        IO.inspect(response)
      end
      def dod do
        {:ok, updates} = Telegram.Api.request(@token, "getUpdates")

# Inspect the `updates` to see if there are new messages
      IO.inspect(updates)
      end
      def get_user_info do

      end



  end




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
      #end)
    # end

    # Fallback for other data types


  #def process_files(contents) do
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

#end
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
