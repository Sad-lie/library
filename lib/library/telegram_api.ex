defmodule Library.TelegramAPI do
  def get_updates(token) do
    url = "https://api.telegram.org/bot#{token}/getUpdates" # Make sure this URL is correct

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        updates = Jason.decode!(body)["result"]
        {:ok, updates}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch updates, status code: #{status_code}"}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
