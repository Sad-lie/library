defmodule LibraryWeb.TelegramController do
  use LibraryWeb, :controller
  require Logger
  alias HTTPoison
  import Ecto.Query, warn: false
  alias Library.Repo
  alias Library.Schema.Book
  alias Library.Schema.Content
  @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
  @base_url "https://api.telegram.org/"


  @spec send_message(any(), any()) :: none()
  def send_message(text, chat_id, opts \\ %{}) do
    params =
      %{
        chat_id: chat_id,
        text: text,
        disable_notification: true
      }
      |> Map.merge(opts)

    Telegram.Api.request(@token, "sendMessage", params)
  end

  def get_file(file_id) do
    Telegram.Api.request(@token, "getFile", file_id: file_id)
  end

  def get_file_path(file_id) do
    {:ok, %{"file_path" => file_path}} = Telegram.Api.request(@token, "getFile", file_id: file_id)
    {:ok, file} = Telegram.Api.file(@token, file_path)
  end

  def sendMessage(text, chat_id)
    do
      Telegram.Api.request(@token, "sendMessage",
        chat_id: chat_id,
        text: "#{text}",
        disable_notification: true
      )
end
def get_book_and_contents(file_name) do
  query =
    from b in Book,
      join: c in Content,
      on: b.telegram_id == c.telegram_id,
      where: b.name == ^file_name,
      select: {b, c},
      order_by: [asc: c.chapter]

  case Repo.all(query) do
    [] ->
      nil

    results ->
      book = List.first(results) |> elem(0)
      contents = Enum.map(results, fn {_, content} -> content end)
      {book, contents}
  end
end

def iterate_through_map(book_name,chat_id) do
  latest_interval =
    Library.Schema.Interval
    |> Library.Repo.all()
    |> Enum.sort_by(&(&1.inserted_at), &>=/2)
    |> List.first()

  interval = latest_interval.interval
  book_name_string = to_string(book_name)

  case get_book_and_contents(book_name_string) do
    nil ->
      IO.puts("Book data does not exist")
      sendMessage("Book data does not exist", chat_id)

    {book, contents} ->
      Enum.each(contents, fn content ->
        Process.sleep(interval)
        IO.puts("Chapter: #{content.chapter}, Data: #{content.data}")
        sendMessage("#{content.data}", chat_id)
      end)

      {:ok, contents}
  end
end

  def req(chat_id, text_input, keyboard_markup) do
    Telegram.Api.request(@token, "sendMessage",
      chat_id: chat_id,
      text: text_input,
      reply_markup: keyboard_markup
    )
  end
end


  # def iterate_through_map(book_name) do
  #   latest_interval =
  #     Library.Schema.Interval
  #     |> Library.Repo.all()
  #     |> Enum.sort_by(& &1.inserted_at, &>=/2)
  #     |> List.first()

  #   interval = latest_interval.interval

  #   book_name_string = to_string(book_name)

  #   case Library.Books.get_book_by_name(book_name_string) do
  #     true ->
  #       query = from(b in Content, where: b.name == ^book_name_string, select: %{name: b.data})
  #       books = Repo.all(query)
  #     {:ok, books} ->
  #       Enum.map(books, fn {key, value} ->
  #         Process.sleep(interval)
  #         IO.puts("Key: #{key}, Value: #{value}")

  #         Telegram.Api.request(@token, "sendMessage",
  #           chat_id: @chat_id,
  #           text: value,
  #           disable_notification: true
  #         )
  #       end)
  #     _error ->
  #       IO.puts("Failed to retrieve book data")
  #       false -> Telegram.sendMessage("book data doesnt not exist", chat_id)
  #       _-> Telegram.sendMessage("Something Else went wrong", chat_id)
  #   end
  # end
          # Telegram.Api.request(
        #   @token,
        #   "sendMessage",
        #   chat_id: @chat_id,
        #   text: content.data,
        #   disable_notification: true
        #)
