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
  @colors_list ["red", "white"]
  @crus_list ["village", "1er cru", "grand cru", "_"]
  @climats_list ["Champs Martin", "Fromange", "_"]

  @doc """
  Generate a QR code for the given wine parameters if they are valid.
  valid parameters are checked against predefined lists.
  Returns :ok if successful, otherwise prints an error message.
  1. Constructs a URL based on the appellation and year.
  2. Generates a QR code from the URL. The URl format is "https://qr.aubigny.wine/<appellation>_<climate>_<cru>_<color>_<year>.html"
  3. Saves the QR code as a PNG file named "QRCODE_<appellation>_<year>.png".
  4. If parameters are invalid, prints an error message with valid options.
  ## Examples

      iex> MQrcode.generate_qrcode(2020, "mercurey", "red", "Champs Martin", "1er cru")
      :ok
      Generates a QR code and saves it as "QRCODE_mercurey_2020.png"
      iex> MQrcode.generate_qrcode("invalid", "Champs Martin", "red", "1er cru")
      Invalid parameters. Please check the appellation, climat, cru, color, and year. must be in the predefined lists.
      Valid appellations: mercurey, rully, bourgogne
      Valid crus: village, 1er cru, grand cru
      Valid climats: Champs Martin, Fromange
      Valid colors: red, white
  5. generate a html file with basic information about the wine in /var/www/qr.aubigny.wine/<appellation>\_<climate>\_<cru>\_<color>\_<year>.html
  """
  def generate_qrcode(year, "bourgogne", color),
    do: generate_qrcode(year, "bourgogne", color, "_", "_")
  
  def generate_qrcode(year, appellation, color, climat, cru)
  when appellation in @appelations_list
  and climat in @climats_list
  and cru in @crus_list
  and color in @colors_list do
    link = "#{appellation}_#{climat}_#{cru}_#{color}_#{year}"
    |> String.replace("_", " ")
    |> String.replace(~r/\s+/, "_")
    |> String.downcase()
    
    "https://qr.aubigny.wine/#{link}.html"
    |> QRCode.create(:high)
    |> QRCode.render(:png)
    |> QRCode.save("QRCODE_#{link}.png")

    if File.exists?("/var/www/qr.aubigny.wine") do
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
      
      "/var/www/qr.aubigny.wine/#{link}.html"
      |> String.replace(" ", "_")
      |> String.downcase()
      |> File.write!(html_content)
    else
      IO.puts("Directory /var/www/qr.aubigny.wine/ does not exist. Skipping HTML file generation.")
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
