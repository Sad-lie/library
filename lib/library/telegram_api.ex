# defmodule Library.TelegramAPI do
#   def get_updates(token) do
#     url = "https://api.telegram.org/bot#{token}/getUpdates" # Make sure this URL is correct

#     case HTTPoison.get(url) do
#       {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#         updates = Jason.decode!(body)["result"]
#         {:ok, updates}
#       {:ok, %HTTPoison.Response{status_code: status_code}} ->
#         {:error, "Failed to fetch updates, status code: #{status_code}"}
#       {:error, reason} ->
#         {:error, reason}
#     end
#   end
# end
defmodule Library.TelegramAPI do
  @api_url "https://api.telegram.org/bot"

  # Define the get_updates function to fetch new messages
  def get_updates(token, offset) do
    url = "#{@api_url}#{token}/getUpdates?offset=#{offset}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        updates = decode_response(body)
        {:ok, updates}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch updates. Status code: #{status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Helper function to decode the response body
  defp decode_response(body) do
    body
    |> Jason.decode()
    |> case do
      {:ok, %{"result" => updates}} -> updates
      error -> error
    end
  end
end
