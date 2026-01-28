#!/usr/bin/env elixir

IO.puts("=" |> String.duplicate(60))
IO.puts("QR CODE GENERATION TEST")
IO.puts("=" |> String.duplicate(60))
IO.puts("")

# Define test wines
test_wines = [
  %{
    year: 2024,
    appellation: "mercurey",
    color: "red",
    climat: "Champs Martin",
    cru: "1er cru",
    energy: "312 kJ / 75 kcal",
    description: "Red Mercurey 1er Cru - Champs Martin"
  },
  %{
    year: 2023,
    appellation: "rully",
    color: "white",
    climat: "Fromange",
    cru: "village",
    energy: "320 kJ / 77 kcal",
    description: "White Rully Village - Fromange"
  },
  %{
    year: 2022,
    appellation: "bourgogne",
    color: "white",
    climat: "_",
    cru: "_",
    energy: "305 kJ / 73 kcal",
    description: "White Bourgogne"
  },
  %{
    year: 2024,
    appellation: "mercurey",
    color: "red",
    climat: "Champs Martin",
    cru: "1er cru",
    energy: "315 kJ / 76 kcal",
    description: "Red Mercurey 1er Cru - Different energy"
  }
]

# HTML output directory
html_dir = "/tmp/wine_html_test"

IO.puts("📂 HTML files will be saved to: #{html_dir}")
IO.puts("📸 QR codes will be saved to: #{File.cwd!()}")
IO.puts("")

# Generate QR codes for each wine
Enum.with_index(test_wines, 1)
|> Enum.each(fn {wine, index} ->
  IO.puts("#{index}. Generating: #{wine.description}")
  IO.puts("   Energy: #{wine.energy}")

  MQrcode.generate_qrcode(
    wine.year,
    wine.appellation,
    wine.color,
    wine.climat,
    wine.cru,
    html_dir,
    wine.energy
  )

  IO.puts("")
end)

IO.puts("=" |> String.duplicate(60))
IO.puts("✅ All QR codes generated successfully!")
IO.puts("=" |> String.duplicate(60))
IO.puts("")
IO.puts("📋 Generated files:")
IO.puts("   QR Codes (PNG): ./QRCODE_*.png")
IO.puts("   HTML pages:     #{html_dir}/*.html")
IO.puts("   Organic logo:   #{html_dir}/ab.png")
IO.puts("")
IO.puts("🔍 To view QR codes:")
IO.puts("   open QRCODE_*.png")
IO.puts("")
IO.puts("🌐 To view HTML pages:")
IO.puts("   open #{html_dir}/*.html")
IO.puts("")
