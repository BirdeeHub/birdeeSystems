{ writeText
, writeShellScript
, zsh
, tx ? null
, shellStr ? null
, extraToml ? ""
, font_string ? "FiraMono Nerd Font"
, maximizer ? null
, ...
}:
writeText "alacritty.toml" (let
  shelly = if shellStr == null then "${zsh}/bin/zsh" else shellStr;
  launchScript = writeShellScript "mysh" /*bash*/ ''
    ${if maximizer == null then "" else "${maximizer} Alacritty > /dev/null 2>&1 &"}
    exec ${if tx == null then "${shelly} -l" else "${tx}/bin/tx"}
  '';
in /*toml*/''
  # https://alacritty.org/config-alacritty.html
  # [env]
  # TERM = "xterm-256color"

  [shell]
  program = "${launchScript}"

  [window]
  startup_mode = "Fullscreen"

  [font]
  size = 11.0

  [font.bold]
  family = "${font_string}"
  style = "Bold"

  [font.bold_italic]
  family = "${font_string}"
  style = "Bold Italic"

  [font.italic]
  family = "${font_string}"
  style = "Italic"

  [font.normal]
  family = "${font_string}"
  style = "Regular"

  ${extraToml}
'')
