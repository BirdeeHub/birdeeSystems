{ config, pkgs, self, inputs, lib, ... }: {
  imports = [];
  options = {
    birdeeMods.tmux = with lib.types; {
      enable = lib.mkOption {
        default = false;
        type = bool;
        description = "enable birdee's tmux configuration";
      };
    };
  };
  config = lib.mkIf config.birdeeMods.tmux.enable (let
    tmuxLaunchScript = pkgs.writeShellScript "tmuxAlias1" (/*bash*/''
      unattached_tmux_sessions=$(tmux list-sessions | grep -v "(attached)")
      number_of_unattached=$(echo "$unattached_tmux_sessions" | wc -l)
      if [ "$number_of_unattached" != "0" ]; then
        selected_session=$(echo "$unattached_tmux_sessions" | head -n 1)
        selected_session_name=''${selected_session%: [0-9]*}
        tmux new-session -At $selected_session_name
      else
        tmux new-session -At $(tmux list-sessions | wc -l)
      fi
    '');
  in {
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set -g display-panes-colour default
        set -g default-terminal "alacritty"
        set -ga terminal-overrides ",alacritty:RGB"
        set-option -g prefix C-Space
        set-option -g prefix2 C-b
      '';
    };
    home.shellAliases = {
      tx = "${tmuxLaunchScript}";
    };
  });
}
