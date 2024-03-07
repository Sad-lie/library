defmodule LibraryWeb.LibraryController do
    def unzip_epub(file_path) do
      case File.read(file_path) do
        {:ok, content} ->
          case :zip.unzip(content) do
            {:ok, ext_files} ->
                IO.puts("EPUB successfully unzipped!")
                ext_files |> Enum.map(&to_string/1) |> ext_xhtml() |> Enum.map(&on_files/1)|> IO.inspect()

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

      # Extract the text content
      text_content = Floki.text(parsed_content)

      text_content
    end

    def filter_xhtml(xhtml) do
      {:ok, parsed_html} = Floki.parse_document(xhtml)
      IO.inspect(parsed_html, label: "Parsed HTML")  # Debug statement

      p_tags = Floki.find(parsed_html, "ns|p")
      IO.inspect(p_tags, label: "P tags")  # Debug statement

      Enum.map(p_tags, &Floki.raw_html/1)
    end

    def uno(x) do
      filter_xhtml(x) |> nolist() |> maper()
    end

    def ext_xhtml(files) do
      Enum.filter(files, fn file -> String.contains?(file, ".xhtml")end)
    end
    def start do
      unzip_epub("/home/liar/Downloads/Wonderland.epub") # here the path

    end

    def file(list) do
      Enum.map(list,fn x -> File.read(x)|> tuple() |> Floki.parse_document() end)
    end
    def tuple({:ok ,y}), do: y

    def on_files(file_paths) when is_list(file_paths) do
      Enum.map(file_paths, fn file_path ->
        # case File.read(file_path) do
        #   {:ok, content} ->
             uno(file_path)end)
        #     perform_action_on_content(content)
        #   {:error, reason} ->
        #     IO.puts("Failed to read #{file_path}: #{reason}")
        #end
      #end

    end
    def on_files(file_path) when is_binary(file_path) do
      on_files([file_path])
    end
    def perform_action_on_content(content) do
      IO.inspect(content)
    end
    #
    end
  #end
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
