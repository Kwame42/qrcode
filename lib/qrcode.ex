defmodule MQrcode do
  @moduledoc """
  Generate a QR code for a wine bottle based on its appellation, climat, cru, color, and year.

  ## Example

      iex> MQrcode.hello("mercurey", "Champs Martin", "1er cru", "red", 2020)
      :ok
      Generates a QR code and saves it as "QRCODE_mercurey_2020.png"
      iex> MQrcode.hello("invalid", "Champs Martin", "1er cru", "red", 2020)
      Invalid parameters. Please check the appellation, climat, cru, color, and year. must be in the predefined lists.
      Valid appellations: mercurey, rully, bourgogne
      Valid crus: village, 1er cru, grand cru
      Valid climats: Champs Martin, Fromange
      Valid colors: red, white
  """
  @appelations_list ["mercurey", "rully", "bourgogne"]
  @crus_list ["village", "1er cru", "grand cru"]
  @climats_list ["Champs Martin", "Fromange"]
  @colors_list ["red", "white"]

  
  @doc """
  Generate a QR code for the given wine parameters if they are valid.
  valid parameters are checked against predefined lists.
  Returns :ok if successful, otherwise prints an error message.
  1. Constructs a URL based on the appellation and year.
  2. Generates a QR code from the URL. The URl format is "https://qr.aubigny.wine/<appellation>_<climate>_<cru>_<color>_<year>.html"
  3. Saves the QR code as a PNG file named "QRCODE_<appellation>_<year>.png".
  4. If parameters are invalid, prints an error message with valid options.
  ## Examples

      iex> MQrcode.generate_qrcode("mercurey", "Champs Martin", "1er cru", "red", 2020)
      :ok
      Generates a QR code and saves it as "QRCODE_mercurey_2020.png"
      iex> MQrcode.generate_qrcode("invalid", "Champs Martin", "1er cru", "red", 2020)
      Invalid parameters. Please check the appellation, climat, cru, color, and year. must be in the predefined lists.
      Valid appellations: mercurey, rully, bourgogne
      Valid crus: village, 1er cru, grand cru
      Valid climats: Champs Martin, Fromange
      Valid colors: red, white
  5. generate a html file with basic information about the wine in /var/www/html/<appellation>_<climate>_<cru>_<color>_<year>.html
  """
  def generate_qrcode(appellation, climat, cru, color, year)
  when appellation in @appelations_list
  and climat in @climats_list
  and cru in @crus_list
  and color in @colors_list do
    "https://qr.aubigny.wine/#{appellation}_#{climat}_#{cru}_#{color}_#{year}.html"
    |> QRCode.create(:high)
    |> QRCode.render(:png)
    |> QRCode.save("QRCODE_#{appellation}_#{climat}_#{cru}_#{color}_#{year}.png")

    if File.exists?("/var/www/html") do
      html_content = """
      <html>
      <head><title>Wine Information</title></head>
      <body>
      <h1>Wine Information</h1>
      <p>Appellation: #{appellation}</p>
      <p>Climat: #{climat}</p>
      <p>Cru: #{cru}</p>
      <p>Color: #{color}</p>
      <p>Year: #{year}</p>
      </body>
      </html>
      """

      File.write!("/var/www/html/#{appellation}_#{climat}_#{cru}_#{color}_#{year}.html", html_content)
    else
      IO.puts("Directory /var/www/html does not exist. Skipping HTML file generation.")
    end
  end

  def generate_qrcode(_, _, _, _, _) do
    """
    Invalid parameters. Please check the appellation, climat, cru, color, and year. must be in the predefined lists.
    Valid appellations: #{Enum.join(@appelations_list, ", ")}
    Valid crus: #{Enum.join(@crus_list, ", ")}
    Valid climats: #{Enum.join(@climats_list, ", ")}
    Valid colors: #{Enum.join(@colors_list, ", ")}
    """ |> IO.puts()
  end
end
