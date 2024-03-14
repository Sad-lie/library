
defmodule LibraryWeb.TelegramController do
  use LibraryWeb, :controller

   @chat_id 977236716
   @token "6572036459:AAHCV5wzjPtrq1nBzodbzhDpkROpZkHQrho"
   @base_url "https://api.telegram.org/"



   def start_menu do
    #  "Register", "add user to database",
    #  "Upload a book",
    #  "library"
   end

   def action_menu do
  #  "upload epub" |> "Uploaded succesfuly"  |> "Set intrvael " |> "getting the parse messeage"
   end

   def library_menu do
   #  "list"
   end

   def book_menu do
    # "select chapter"
    #  "select intravel"
    #  "start / pause"
   end

  def sendMessage(text,chat_id) ,do: Telegram.Api.request(@token, "sendMessage", chat_id: chat_id, text: "#{text}", disable_notification: true)



  def iterate_through_map(map, interval \\ 5000) do
    #   map = %{}#sender() # Make sure this gets your map as expected.
        Enum.each(map, fn {key, value} ->
         Process.sleep(interval)
         IO.puts("Key: #{key}, Value: #{value}")
         text = value
         Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)
    end)
  end

  def keyboard(list_of_keyboard, text_option,chat_id) do
        keyboard_markup = %{one_time_keyboard: true, keyboard: list_of_keyboard}
        Telegram.Api.request(@token, "sendMessage", chat_id: chat_id, text: "#{text_option}", reply_markup: {:json, keyboard_markup})
end

def istart do
  x = [["one","two","three"],["one","two","three"],["one","two","three"]]
  keyboard(x,"choose one" ,@chat_id)
end

def button(list_of_options,text_input,chat_id) do
  buttons = Enum.map(list_of_options ,&option_maker/1)
  keyboard_markup = %{
    inline_keyboard: buttons
  }
  Telegram.Api.request(@token, "sendMessage", chat_id: chat_id, text: "#{text_input}", reply_markup: keyboard_markup)
end
def option_maker(input) ,do: [%{text: "#{input}", callback_data: "#{input}"}]
end


# def handle_update(%{"message" => %{"document" => document}} = _update) do
#   # Extract the MIME type and file ID from the document
#   mime_type = document["mime_type"]
#   file_id = document["file_id"]

#   # Check if the MIME type is for an EPUB file
#   if mime_type == "application/epub+zip" do
#     # Use the `getFile` method to get the file path
#     {:ok, file_path} = Telegram.Api.request(@token, "getFile", file_id: file_id)

#     # Construct the download URL and download the file
#     _download_url = "https://api.telegram.org/file/bot#{@token}/#{file_path}"
#     # Add your code to download the file using the download_url

#     # Proceed with your logic for handling EPUB files
#     # ...
#   else
#     # Handle other file types or send a message to the user
#     # ...

#   end
#   # Set your bot token and your server's URL
# end

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

  # def buttons do
  #   # Define your inline keyboard buttons
  #      buttons = [
  #         [%{text: "Option 1", callback_data: "option_1"}],
  #         [%{text: "Option 2", callback_data: "option_2"}]
  #       ]

  # # Create the inline keyboard markup
  #       keyboard_markup = %{
  #         inline_keyboard: buttons
  #       }

  # # Send a message with the inline keyboard
  #       Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: "Choose an option:", reply_markup: keyboard_markup)
  # end
#   def keyboard() do
#     keyboard = [
#      ["A0", "A1"],
#      ["B0", "B1", "B2"]
#     ]
#    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}
#    Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: "Here a keyboard!", reply_markup: {:json, keyboard_markup})
# end













  #def sender do
    #   _text = %{
    #      12 => "  'Pepper, mostly,' said the cook.", 18 => "  'You're a very poor speaker,' said the King.",
    #   11 => "  'It began with the tea,' the Hatter replied.", 19 => "  'Not yet, not yet!' the Rabbit hastily interrupted.  'There's\na great deal to come before that!'",
    #   10 => "  'I'd rather finish my tea,' said the Hatter, with an anxious\nlook at the Queen, who was reading the list of singers.",
    #   9 => "  'I'm a poor man,' the Hatter went on, 'and most things\ntwinkled after that--only the March Hare said--'",
    #   8 => "  'I didn't!' the March Hare interrupted in a great hurry.",
    #   7 => "  'Write that down,' the King said to the jury, and the jury\neagerly wrote down all three dates on their slates, and then\nadded them up, and reduced the answer to shillings and pence.",
    #   5 => "  The first witness was the Hatter.  He came in with a teacup in\none hand and a piece of bread-and-butter in the other.  'I beg\npardon, your Majesty,' he began, 'for bringing these in:  but I\nhadn't quite finished my tea when I was sent for.'",
    #   6 => "  'Call the first witness,' said the King; and the White Rabbit\nblew three blasts on the trumpet, and called out, 'First\nwitness!'",
    #   4 => "  'You may go,' said the King, and the Hatter hurriedly left the\ncourt, without even waiting to put his shoes on.",
    #   2 => "  Alice had never been in a court of justice before, but she had\nread about them in books, and she was quite pleased to find that\nshe knew the name of nearly everything there.  'That's the\njudge,' she said to herself, 'because of his great wig.'",
    #   3 => "  'Stupid things!' Alice began in a loud, indignant voice, but\nshe stopped hastily, for the White Rabbit cried out, 'Silence in\nthe court!' and the King put on his spectacles and looked\nanxiously round, to make out who was talking.",
    #   1 => "\n  The King and Queen of Hearts were seated on their throne when\nthey arrived, with a great crowd assembled about them--all sorts\nof little birds and beasts, as well as the whole pack of cards:\nthe Knave was standing before them, in chains,
    #         with a soldier on\neach side to guard him; and near the King was the White Rabbit,\nwith a trumpet in one hand, and a scroll of parchment in the\nother.  In the very middle of the court was a table, with a large\ndish of tarts upon it:  they looked so good, that it made Alice\n
    #         quite hungry to look at them--'I wish they'd get the trial done,'\nshe thought, 'and hand round the refreshments!'  But there seemed\nto be no chance of this, so she began looking at everything about\nher, to pass away the time.",
    #   13 => "  Alice could see, as well as if she were looking over their\nshoulders, that all the jurors were writing down 'stupid things!'\non their slates, and she could even make out that one of them\ndidn't know how to spell 'stupid,' and that he had to ask his\nneighbour to tell him.  'A nice muddle their slates'll be in\nbefore the trial's over!' thought Alice.",
    #   14 => "  The judge, by the way, was the King; and as he wore his crown\nover the wig, (look at the frontispiece if you want to see how he\ndid it,) he did not look at all comfortable, and it was certainly\nnot becoming.",
    #   15 => "  'Come, that finished the guinea-pigs!' thought Alice.  'Now we\nshall get on better.'",
    #   16 => "  'I can't go no lower,' said the Hatter:  'I'm on the floor, as\nit is.'",
    #   17 => "  The Hatter looked at the March Hare, who had followed him into\nthe court, arm-in-arm with the Dormouse.  'Fourteenth of March, I\nthink it was,' he said."}

    #  # Telegram.Api.request(@token, "sendMessage", chat_id: @chat_id, text: text, disable_notification: true)

    #   end
