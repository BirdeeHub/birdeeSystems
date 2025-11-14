{
  pkgs,
  writeText,
  writeShellScriptBin,
  lib,
  alacritty,
  fontconfig,
  zsh,
  nerdString ? "FiraMono",
  wrapZSH ? false,
  extraTOML ? "",
  autotx ? true,
  zdotdir ? null,
  tmux,
  extraPATH ? [ ],
  ...
}@args:
let

  tmuxf = tmux.wrap {
    terminal = "alacritty";
    updateEnvironment = (if wrapZSH && zdotdir != null then [ "ZDOTDIR" ] else []);
  };

  alakitty-toml = # toml
    ''
      # https://alacritty.org/config-alacritty.html
      # [env]
      # TERM = "xterm-256color"

      [shell]
      program = "${zsh}/bin/zsh"
      args = [ "-l"${if autotx then '', "-c", "exec ${tmuxf}/bin/tx"'' else ""} ]

      [font]
      size = 11.0

      [font.bold]
      family = "${nerdString} Nerd Font"
      style = "Bold"

      [font.bold_italic]
      family = "${nerdString} Nerd Font"
      style = "Bold Italic"

      [font.italic]
      family = "${nerdString} Nerd Font"
      style = "Italic"

      [font.normal]
      family = "${nerdString} Nerd Font"
      style = "Regular"

      ${extraTOML}
    '';

  alakitty = writeShellScriptBin "alacritty" (
    let
      final-alakitty-toml = writeText "alakitty.toml" alakitty-toml;

      # newDejaVu = {
      #   minimal = pkgs.nerdfonts.fira-code;
      # };
      #
      # newFC = fontconfig.override (prev: {
      #   dejavu_fonts = newDejaVu;
      # });

      # newAlacritty = alacritty.override (prev: {
      #   fontconfig = newFC;
      # });
    in
    # bash
    ''
      export PATH=${lib.makeBinPath extraPATH}:$PATH
      ${if wrapZSH && zdotdir != null then "export ZDOTDIR=${zdotdir}" else ""}
      exec ${alacritty}/bin/alacritty --config-file ${final-alakitty-toml} "$@"
    ''
  );
in
alakitty
