defmodule Library.TelegramPoller do
  use GenServer
  alias LibraryWeb.MyFile
  alias Library.TelegramAPI
  alias LibraryWeb.TelegramController, as: Telegram
  alias Library.TelegramProcessor, as: Processor
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


#Processor

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
             Processor.process_documents(first_name, last_name, username, chat_id, file_id, file_name)
         _-> IO.inspect(update)
      end

  end

    def process_text_message(text, chat_id, first_name, last_name, username) do
      case text do
        "/chapter" -> Processor.process_chapter(chat_id,first_name, last_name, username)
        "/list" -> Processor.process_list(chat_id,first_name, last_name, username)
        "/interval" -> Processor.process_intervel(chat_id,first_name, last_name, username)
        "/start" -> Processor.process_start(chat_id,first_name, last_name, username)
        "/help" -> Telegram.sendMessage("No help available for you", chat_id)
        "/cancel" -> Telegram.sendMessage("Cancelled", chat_id)
        text -> Telegram.sendMessage(" Did you said ..... #{text} ? \nOK....try again.", chat_id)
        _ -> Telegram.sendMessage("Invalid command. Please try again.", chat_id)
      end
    end


  def process_callback_query(data, chat_id,first_name, last_name, username,in_text) do
    case in_text do
      "Here are the list of Chapters, please select one:"-> Processor.handle_callback_chapter(data,chat_id,first_name, last_name, username)
      "Here are the list of books, please select one:"-> Processor.handle_callback_list(data,chat_id,first_name, last_name, username)
      "Select the interval:"-> Processor.handle_callback_interval(data,chat_id,first_name, last_name, username)
      _ -> Telegram.sendMessage("Some Issue with the call back", chat_id)
    end
  end
end
