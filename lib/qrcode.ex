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
  3. Saves the QR code as a PNG file named "QRCODE_<appellation>_<climate>_<cru>_<color>_<year>_<lot number>.png", where <lot number> is autogenareted by reading the QRCODE_*.png files in the current directory and incrementing the highest lot number (form M<num>) where num is a 4 digit number, and increase by 1.
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
  def generate_qrcode(year, appellation, color, climat \\ "_", cru \\ "_", html_directory \\ "/var/www/qr.aubigny.wine", energy \\ "312 kJ / 75 kcal")

  def generate_qrcode(year, appellation, color, climat, cru, html_directory, energy)
  when appellation in @appelations_list
  and climat in @climats_list
  and cru in @crus_list
  and color in @colors_list do
    link = "#{appellation}_#{climat}_#{cru}_#{color}_#{year}_#{lot_number()}"
    |> String.replace("_", " ")
    |> String.replace(~r/\s+/, "_")
    |> String.downcase()

    qr_filename = "QRCODE_#{link}.png"

    "https://qr.aubigny.wine/#{link}.html"
    |> QRCode.create(:high)
    |> QRCode.render(:png)
    |> QRCode.save(qr_filename)

    # Add energy information text to the QR code image
    add_energy_text_to_qrcode(qr_filename, energy)

    if File.exists?(html_directory) do
      template_path = Path.join(:code.priv_dir(:qrcode), "template/wine.html.eex")

      # Copy organic logo to output directory if not already present
      logo_source = Path.join(:code.priv_dir(:qrcode), "template/ab.png")
      logo_dest = Path.join(html_directory, "ab.png")
      unless File.exists?(logo_dest) do
        File.cp!(logo_source, logo_dest)
      end

      html_content = EEx.eval_file(template_path,
        assigns: [
          year: year,
          appellation: appellation,
          climat: climat,
          cru: cru,
          color: color,
          has_organic_logo: File.exists?(logo_dest),
          energy: energy
        ]
      )

      Path.join(html_directory, "#{link}.html")
      |> String.replace(" ", "_")
      |> String.downcase()
      |> File.write!(html_content)
    else
      IO.puts("Directory #{html_directory} does not exist. Skipping HTML file generation.")
    end
  end

  def generate_qrcode(_, _, _, _, _, _, _) do
    """
    Invalid parameters. Please check the appellation, climat, cru, color, and year. must be in the predefined lists.
    Valid appellations: #{Enum.join(@appelations_list, ", ")}
    Valid crus: #{Enum.join(@crus_list, ", ")}
    Valid climats: #{Enum.join(@climats_list, ", ")}
    Valid colors: #{Enum.join(@colors_list, ", ")}
    """ |> IO.puts()
  end

  defp lot_number do
    case File.ls!(".")
	 |> Enum.filter(&String.starts_with?(&1, "QRCODE_"))
	 |> Enum.map(fn file ->
	   case Regex.run(~r/QRCODE_.*_(M\d{4})\.png$/, file) do
	     [_, lot] -> String.slice(lot, 1..-1//1) |> String.to_integer()
	     _ -> 0
	   end
	 end)
	 |> Enum.max(fn -> 0 end) do
	   0 -> "LM0001"
	   max_lot -> "LM" <> Integer.to_string(max_lot + 1) |> String.pad_leading(4, "0")
	 end
  end

  defp add_energy_text_to_qrcode(filename, energy) do
    # Format energy text: E(100ml)=312kJ/75kcal
    energy_text = "E(100ml)=#{energy |> String.replace(" ", "")}"

    # Try ImageMagick 7 (magick) first, then fall back to ImageMagick 6 (convert)
    magick_cmd = case System.cmd("magick", ["-version"], stderr_to_stdout: true) do
      {_, 0} -> "magick"
      _ -> case System.cmd("convert", ["-version"], stderr_to_stdout: true) do
        {_, 0} -> "convert"
        _ -> nil
      end
    end

    case magick_cmd do
      nil ->
        IO.puts("⚠ ImageMagick not found. QR code generated without text.")
      cmd ->
        # Step 1: Add white space at top for header (70px)
        System.cmd(cmd, [
          filename,
          "-background", "white",
          "-splice", "0x70",
          "-gravity", "North",
          filename
        ])

        # Step 2: Add "INGREDIENT &" at top
        System.cmd(cmd, [
          filename,
          "-gravity", "North",
          "-pointsize", "24",
          "-annotate", "+0+10",
          "INGREDIENT &",
          filename
        ])

        # Step 3: Add "NUTRITION" below first line
        System.cmd(cmd, [
          filename,
          "-gravity", "North",
          "-pointsize", "24",
          "-annotate", "+0+38",
          "NUTRITION",
          filename
        ])

        # Step 4: Add white space at bottom for energy (60px)
        System.cmd(cmd, [
          filename,
          "-background", "white",
          "-splice", "0x60",
          "-gravity", "South",
          filename
        ])

        # Step 5: Add energy text at bottom
        System.cmd(cmd, [
          filename,
          "-gravity", "South",
          "-pointsize", "24",
          "-annotate", "+0+15",
          energy_text,
          filename
        ])

        IO.puts("✓ Added header and energy info to QR code")
    end
  end
 end
