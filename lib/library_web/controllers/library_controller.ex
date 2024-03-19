defmodule LibraryWeb.LibraryController do
  use Telegram.Bot

  alias Library.Users

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
            |> ext_xhtml() |> IO.inspect()
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
    parsed_content =
      Floki.parse_document(xhtml)
      # Get the parsed HTML tree
      |> elem(1)

    _text_content = Floki.text(parsed_content)
  end

  def filter_para(xhtml) do
    {:ok, parsed_html} = Floki.parse_document(xhtml)
    # IO.inspect(parsed_html, label: "Parsed HTML")
    p_tags = Floki.find(parsed_html, "p")
    # IO.inspect(p_tags, label: "P tags")
    Enum.map(p_tags, &Floki.raw_html/1)
  end

  def filter_meta(xhtml) do
    {:ok, parsed_html} = Floki.parse_document(xhtml)
    # IO.inspect(parsed_html, label: "Parsed HTML")
    p_tags = Floki.find(parsed_html, "title")
    # IO.inspect(p_tags, label: "P tags")
    Enum.map(p_tags, &Floki.raw_html/1)
  end

  def ext_xhtml(files) do
    Enum.filter(files, fn file -> String.contains?(file, ".xhtml") end)
  end

  def unlist([x]), do: x

  def nofile(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        _x =
          filter_meta(content)
          |> nolist()
          |> maper()
          |> insert()

      {:error, reason} ->
        IO.puts("Failed to read #{file_path}: #{reason}")
    end
  end
  def on_files(file_paths) when is_list(file_paths) do
    Enum.map(file_paths, fn file_path ->
      # Extract chapter name from file_path, assuming the chapter name is the file's base name without the extension
      chapter_name = file_path |> Path.basename() |> Path.rootname()

      case File.read(file_path) do
        {:ok, content} ->
          processed_content =
            content
            |> filter_para()
            |> nolist()
            |> maper()

          # Use chapter_name directly instead of extracting title from content
          title = chapter_name

          changeset =
            %Library.Schema.Book{}
            |> Ecto.Changeset.change(%{data: processed_content, name: title})

          case Library.Repo.insert(changeset) do
            {:ok, _record} -> IO.puts("#{title} inserted successfully.")
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

  def on_files(file_path) when is_binary(file_path) do
    on_files([file_path])
  end

  def action(content) do
    filter_para(content)
    |> nolist()
    |> maper()
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
