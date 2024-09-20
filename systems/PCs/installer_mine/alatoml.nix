{ callPackage
, writeText
, writeShellScript
, tx ? null
, shellStr ? null
, extraToml ? ""
, maximize_program ? null
, ...
}: let
  alakitty-toml = { zsh, xorg, ... }: let

    shelly = if shellStr == null then "${zsh}/bin/zsh" else shellStr;

    resizer = if maximize_program == null then "" else "${maximize_program}/bin/maximize_program Alacritty > /dev/null 2>&1 &";

    launchScript = writeShellScript "mysh" /*bash*/ ''
      ${resizer}
      exec ${if tx == null then "${shelly} -l" else "${tx}/bin/tx"}
    '';

  in (/*toml*/''
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
    family = "FiraMono Nerd Font"
    style = "Bold"

    [font.bold_italic]
    family = "FiraMono Nerd Font"
    style = "Bold Italic"

    [font.italic]
    family = "FiraMono Nerd Font"
    style = "Italic"

    [font.normal]
    family = "FiraMono Nerd Font"
    style = "Regular"
  '');

in
writeText "alacritty.toml" (builtins.concatStringsSep "\n" [
  (callPackage alakitty-toml { })
  extraToml
])
