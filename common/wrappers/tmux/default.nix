inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  mkColor =
    default:
    lib.mkOption {
      type = lib.types.str;
      inherit default;
    };
in
{
  _file = ./default.nix;
  key = ./default.nix;
  imports = [ wlib.wrapperModules.tmux ];
  options.colors = lib.mkOption {
    type = lib.types.submodule {
      options = {
        black = mkColor "#282c34";
        blue = mkColor "#61afef";
        yellow = mkColor "#e5c07b";
        red = mkColor "#e06c75";
        white = mkColor "#aab2bf";
        green = mkColor "#98c379";
        visual_grey = mkColor "#3e4452";
        comment_grey = mkColor "#5c6370";
      };
    };
  };
  config.colors.green = "#80a0ff";
  config.prefix = "C-Space";
  config.terminal = "xterm-256color";
  config.terminalOverrides = ",${config.terminal}:RGB";
  config.secureSocket = true;
  config.statusKeys = "vi";
  config.modeKeys = "vi";
  config.vimVisualKeys = true;
  config.disableConfirmationPrompt = true;
  config.configBefore = /* tmux */ ''
    bind-key -N "Select the previously current window" C-p last-window
    bind-key -N "Switch to the last client" P switch-client -l

    bind -r -N "Resize the pane left" H resize-pane -L
    bind -r -N "Resize the pane down" J resize-pane -D
    bind -r -N "Resize the pane up" K resize-pane -U
    bind -r -N "Resize the pane right" L resize-pane -R

    bind -r -N "Resize the pane left by 5" C-H resize-pane -L 5
    bind -r -N "Resize the pane down by 5" C-J resize-pane -D 5
    bind -r -N "Resize the pane up by 5" C-K resize-pane -U 5
    bind -r -N "Resize the pane right by 5" C-L resize-pane -R 5

    bind -r -N "Move the visible part of the window left" M-h refresh-client -L 10
    bind -r -N "Move the visible part of the window up" M-j refresh-client -U 10
    bind -r -N "Move the visible part of the window down" M-k refresh-client -D 10
    bind -r -N "Move the visible part of the window right" M-l refresh-client -R 10
  '';
  config.plugins = [
    # pkgs.tmuxPlugins.onedark-theme
    (let
      pname = "tmux-onedark-custom";
      plugin = pkgs.runCommand pname {
        src = pkgs.replaceVars ./tmux-onedark-theme.tmux (builtins.mapAttrs (_: wlib.escapeShellArgWithEnv) config.colors // { inherit (pkgs) bash; });
      } "mkdir -p $out; cp $src $out/${pname}.tmux; chmod +x $out/${pname}.tmux";
    in pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = pname;
      version = "master";
      src = plugin;
      rtpFilePath = "${pname}.tmux";
    })
    {
      plugin = (
        pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-navigate";
          version = "master";
          src = inputs.tmux-navigate-src;
          rtpFilePath = "tmux-navigate.tmux";
        }
      );
      configBefore = /* tmux */ ''
        set -g @navigate-left  'h'
        set -g @navigate-down  'j'
        set -g @navigate-up    'k'
        set -g @navigate-right 'l'
        set -g @navigate-back  'C-p'
      '';
    }
  ];
  config.drv.postBuild = let
    tx = /* bash */ ''
      #!${pkgs.bash}/bin/bash
      if [[ $(${placeholder "out"}/bin/tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
        selected_session=$(${placeholder "out"}/bin/tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
        exec ${placeholder "out"}/bin/tmux new-session -At $selected_session
      else
        exec ${placeholder "out"}/bin/tmux new-session
      fi
    '';
  in ''
    echo ${lib.escapeShellArg tx} > $out/bin/tx
    chmod +x $out/bin/tx
  '';
  # module code to include with root installs
  # This is required so that tmux can write to /var/run/utmp
  # (which can be queried with who to display currently connected user sessions).
  # Note, this will add a guid wrapper for the group utmp!
  # see programs.tmux.withUtempter
  options.nixosModule = lib.mkOption {
    readOnly = true;
    type = lib.types.raw;
    default = { pkgs, ... }: {
      config.security.wrappers = {
        utempter = {
          source = "${pkgs.libutempter}/lib/utempter/utempter";
          owner = "root";
          group = "utmp";
          setuid = false;
          setgid = true;
        };
      };
    };
  };
}
