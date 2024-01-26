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
        bind-key P last-window # -N "Select the previously current window"
        bind-key C-p switch-client -l # -N "Switch to the last client"
        set-window-option -g mode-keys vi
        # todo rebind movement and resize and the like to be more vim
        # the rest can stay pretty default I think
        bind h select-pane -L # -N "Select pane to the left of the active pane"
        bind j select-pane -D # -N "Select pane below the active pane"
        bind k select-pane -U # -N "Select pane above the active pane"
        bind l select-pane -R # -N "Select pane to the right of the active pane"

        bind -r H resize-pane -L # -N "Resize the pane left"
        bind -r J resize-pane -D # -N "Resize the pane down"
        bind -r K resize-pane -U # -N "Resize the pane up"
        bind -r L resize-pane -R # -N "Resize the pane right"

        bind -r C-H resize-pane -L 5 # -N "Resize the pane left by 5"
        bind -r C-J resize-pane -D 5 # -N "Resize the pane down by 5"
        bind -r C-K resize-pane -U 5 # -N "Resize the pane up by 5"
        bind -r C-L resize-pane -R 5 # -N "Resize the pane right by 5"

        bind -r M-h refresh-client -L 10 # -N "Move the visible part of the window left"
        bind -r M-j refresh-client -U 10 # -N "Move the visible part of the window up"
        bind -r M-k refresh-client -D 10 # -N "Move the visible part of the window down"
        bind -r M-l refresh-client -R 10 # -N "Move the visible part of the window right"

      '';
      disableConfirmationPrompt = true;
      plugins = [ pkgs.tmuxPlugins.onedark-theme ];
    };
    home.packages = [
      tx
    ];
  });
}
