
defmodule LibraryWeb.TelegramController do
  use LibraryWeb, :controller

  def handle_webhook(conn, %{"update" => _update_params}) do
    # update from Telegram
    # ...

    send_resp(conn, 200, "OK")
  end
end
