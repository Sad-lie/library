defmodule LibraryWeb.LibraryController do
  use Telegram.Bot

  alias Library.Users


    def start do
      unzip_epub("/home/liar/elixir/projects/library/lib/library/files/the-idiot.epub")
    end

    def unzip_epub(file_path) when is_binary(file_path) do
      case File.read(file_path) do
        {:ok, content} ->
          case :zip.extract(content) do
            {:ok, ext_files} ->
              IO.puts("EPUB successfully unzipped!")

              ext_files
              |> Enum.map(&to_string/1)
              |> ext_xhtml()
              |> IO.inspect()
              |> Enum.map(&on_files/1)

            {:error, reason} ->
              {:error, "Failed to unzip EPUB: #{reason}"}
          end

        {:error, reason} ->
          {:error, "Error reading EPUB file: #{reason}"}
      end
    end

  def unzip_epub(non_binary) do
    IO.inspect(non_binary, label: "Received unexpected data type")
    {:error, "Expected a file path string"}
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
            %Library.Schema.Content{}
            |> Ecto.Changeset.change(%{data: processed_content, chapter: title})

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

defmodule LibraryWeb.MyFile do
  def create_dir_and_write_file(dir_path, file_name, content) do
    # Step 1: Create the directory (and any necessary parent directories)
    case File.mkdir_p(dir_path) do
      :ok -> IO.puts("Directory created successfully.")
      {:error, _} = error -> IO.puts("Error creating directory: #{inspect(error)}")
    end

    # Step 2: Define the full path to the file
    file_path = Path.join(dir_path, file_name)

    # Step 3: Write content to the file
    case File.write(file_path, content) do
      :ok -> IO.puts("File written successfully.")
      {:error, _} = error -> IO.puts("Error writing to file: #{inspect(error)}")
    end
  end
end

  # def unzip_epub(file_path) when is_binary(file_path) do
  #   case File.read(file_path, :binary) do
  #     {:ok, content} ->
  #       case :zip.unzip(content) do

  #         {:ok, ext_files} ->
  #           IO.puts("EPUB successfully unzipped!")

  #           ext_files
  #           |> Enum.map(&to_string/1)
  #           |> ext_xhtml()
  #           |> IO.inspect()
  #           |> Enum.map(&on_files/1)

  #         {:error, reason} ->
  #           {:error, "Failed to unzip EPUB: #{reason}"}
  #       end

  #     {:error, reason} ->
  #       {:error, "Error reading EPUB file: #{reason}"}
  #   end
  # end

  #   case File.read(file_path) do
  #     {:ok, content} ->
  #       case :zip.unzip(content) do
  #         {:ok, ext_files} ->
  #           IO.puts("EPUB successfully unzipped!")

  #           ext_files
  #           |> Enum.map(&to_string/1)
  #           |> ext_xhtml()
  #           |> IO.inspect()
  #           |> Enum.map(&on_files/1)

  #         {:error, reason} ->
  #           {:error, "Failed to unzip EPUB: #{reason}"}
  #       end

  #     {:error, reason} ->
  #       {:error, "Error reading EPUB file: #{reason}"}
  #   end
  # end

  # def unzip_epub(file_path) when is_binary(file_path) do
  #   case File.read(file_path, :binary) do
  #     {:ok, content} ->
  #       case :zip.unzip(content) do

  #         {:ok, ext_files} ->
  #           IO.puts("EPUB successfully unzipped!")

  #           ext_files
  #           |> Enum.map(&to_string/1)
  #           |> ext_xhtml()
  #           |> IO.inspect()
  #           |> Enum.map(&on_files/1)

  #         {:error, reason} ->
  #           {:error, "Failed to unzip EPUB: #{reason}"}
  #       end

  #     {:error, reason} ->
  #       {:error, "Error reading EPUB file: #{reason}"}
  #   end
  # end
  # def action(content) do
  #   filter_para(content)
  #   |> nolist()
  #   |> maper()
  # end

  # def first([head | _tail] = _list) do
  #   action(head)
  # end

  # def first([]), do: :empty_list
