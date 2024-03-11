defmodule Library.TelegramPoller do
  use GenServer

  require Logger

  # GenServer
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  # def start_link(args) do
  #   GenServer.start_link(__MODULE__, args)
  # end
  # def init(_) do
  #   schedule_polling() # Start the polling process
  #   {:ok, %{}}
  # end

  def init(_state) do
    schedule_polling()
    {:ok, %{}}
  end
  # def handle_info(:poll, state) do
  #   fetch_updates() # Replace with actual logic to fetch updates from Telegram

  #   schedule_polling() # Reschedule the next poll
  #   {:noreply, state}
  # end
  # Handle the polling
  def handle_info(:poll, state) do
    fetch_updates()
    schedule_polling()
    {:noreply, state}
  end

  def schedule_polling do
    Process.send_after(self(), :poll, 5_000)
  end

  def fetch_updates do
    # logic to fetch and process Telegram updates callingTelegram API and handling response
    token = Application.get_env(:library, Library.TelegramBot)[:token]
    case Library.TelegramAPI.get_updates(token) do
      {:ok, updates} ->
        Enum.each(updates, &process_update/1)
      {:error, reason} ->
        Logger.error("Failed to fetch updates: #{inspect(reason)}")
    end
  end

  def process_update(update) do
    # Process each update
    Logger.info("Received update: #{inspect(update)}")
    # Further processing
  end
end
