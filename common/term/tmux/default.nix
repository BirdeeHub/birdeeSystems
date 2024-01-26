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
    tx = pkgs.writeShellScriptBin "tx" (/*bash*/''
      if [[ $(tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
        selected_session=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
        tmux new-session -At $selected_session
      else
        tmux new-session
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
        # Remap prefix l to prefix P
        bind-key P last-window
        # todo rebind movement and resize and the like to be more vim
        # the rest can stay pretty default I think
        setw -g mode-keys vi
      '';
      disableConfirmationPrompt = true;
      plugins = [ pkgs.tmuxPlugins.onedark-theme ];
    };
    home.packages = [
      tx
    ];
  });
}
