{
  writeText,
  writeShellScriptBin,
  lib,
  alacritty,
  fontconfig,
  zsh,
  nerdfonts,
  nerdString ? "FiraMono",
  wrapZSH ? false,
  extraTOML ? "",
  autotx ? true,
  zdotdir ? null,
  tmux,
  custom_tx_script ? null,
  extraPATH ? [ ],
  ...
}@args:
let

  tmuxf = tmux.override (prev: {
    term_string = "alacritty";
    passthruvars = (if prev ? passthruvars then prev.passthruvars else []) ++ (if wrapZSH && zdotdir != null then [ "ZDOTDIR" ] else []);
  });

  tx =
    if custom_tx_script != null then
      custom_tx_script
    else
      writeShellScriptBin "tx" # bash
        ''
          if ! echo "$PATH" | grep -q "${tmuxf}/bin"; then
            export PATH=${tmuxf}/bin:$PATH
          fi
          if [[ $(tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
            selected_session=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
            exec tmux new-session -At $selected_session
          else
            exec tmux new-session
          fi
        '';

  alakitty-toml = # toml
    ''
      # https://alacritty.org/config-alacritty.html
      # [env]
      # TERM = "xterm-256color"

      [shell]
      program = "${zsh}/bin/zsh"
      args = [ "-l"${if autotx then '', "-c", "exec ${tx}/bin/tx"'' else ""} ]

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

      newDejaVu = {
        minimal = nerdfonts.override { fonts = [ nerdString ]; };
      };

      newFC = fontconfig.override (prev: {
        dejavu_fonts = newDejaVu;
      });

      newAlacritty = alacritty.override (prev: {
        fontconfig = newFC;
      });
    in
    # bash
    ''
      export PATH=${lib.makeBinPath ([ newFC ] ++ extraPATH)}:$PATH
      ${if wrapZSH && zdotdir != null then "export ZDOTDIR=${zdotdir}" else ""}
      exec ${newAlacritty}/bin/alacritty --config-file ${final-alakitty-toml} "$@"
    ''
  );
in
alakitty
