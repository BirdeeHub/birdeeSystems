{
  writeText,
  writeShellScript,
  writeShellScriptBin,
  lib,
  foot,
  fontconfig,
  zsh,
  nerdfonts,
  nerdString ? "FiraMono",
  callPackage,
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

  fzdotdir = if zdotdir != null then zdotdir else callPackage ./zdot { };

  tmuxf = tmux.override (prev: {
    isAlacritty = true;
    passthruvars = (if prev ? passthruvars then prev.passthruvars else []) ++ (if wrapZSH then [ "ZDOTDIR" ] else []);
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

  footcfg = let
    shelllaunch = writeShellScript "termshell" (if autotx then ''${zsh}/bin/zsh -l -c "exec ${tx}/bin/tx"'' else ''${zsh}/bin/zsh -l'');
  in ''
      shell=${shelllaunch}
      font=${nerdString} Nerd Font:size=11

      ${extraTOML}
    '';

  myfoot = writeShellScriptBin "alacritty" (
    let
      inafoot = writeText "foot.ini" footcfg;

      newDejaVu = {
        minimal = nerdfonts.override { fonts = [ nerdString ]; };
      };

      newFC = fontconfig.override (prev: {
        dejavu_fonts = newDejaVu;
      });

      otherfoot = foot.override (prev: {
        fontconfig = newFC;
      });
    in
    # bash
    ''
      export PATH=${lib.makeBinPath ([ newFC tx tmuxf ] ++ extraPATH)}:$PATH
      ${if wrapZSH then "export ZDOTDIR=${fzdotdir}" else ""}
      exec ${otherfoot}/bin/foot --config=${inafoot} "$@"
    ''
  );
in
myfoot
