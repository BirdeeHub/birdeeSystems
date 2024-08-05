{pkgs, lib, isAlacritty ? false, noNix ? false, ... }: let

    tx = pkgs.writeShellScriptBin "tx" (/*bash*/''
      export PATH=${tmux}/bin:$PATH
      if [[ $(tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
        selected_session=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
        exec tmux new-session -At $selected_session
      else
        exec tmux new-session
      fi
    '');

    plugins = configPlugins [ pkgs.tmuxPlugins.onedark-theme ];

    # tmuxBoolToStr = value: if value then "on" else "off";
    confText = (/* tmux */ ''
      # ============================================= #
      # Start with defaults from the Sensible plugin  #
      # --------------------------------------------- #
      run-shell ${pkgs.tmuxPlugins.sensible.rtp}
      # ============================================= #

      set -g display-panes-colour default
      set -g default-terminal ${if isAlacritty then "alacritty" else "xterm-256color"}
      set -ga terminal-overrides ${if isAlacritty then ''",alacritty:RGB"'' else ''",xterm-256color:RGB"''}
      ${if noNix then ''set -g update-environment "ZDOTDIR"'' else ""}

      set  -g base-index      1
      setw -g pane-base-index 1

      set -g status-keys vi
      set -g mode-keys   vi

      unbind C-b
      set-option -g prefix C-Space
      set -g prefix C-Space
      bind -N "Send the prefix key through to the application" \
        C-Space send-prefix

      bind-key -N "Kill the current window" & kill-window
      bind-key -N "Kill the current pane" x kill-pane

      set  -g mouse             on
      setw -g aggressive-resize off
      setw -g clock-mode-style  12
      set  -s escape-time       500
      set  -g history-limit     2000
      set -gq allow-passthrough on
      set -g visual-activity off

      bind-key -N "Select the previously current window" C-p last-window
      bind-key -N "Switch to the last client" P switch-client -l
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

      bind -N "Select pane to the left of the active pane" h select-pane -L
      bind -N "Select pane below the active pane" j select-pane -D
      bind -N "Select pane above the active pane" k select-pane -U
      bind -N "Select pane to the right of the active pane" l select-pane -R

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

    '') + plugins + ( /* tmux */ ''
    '');

    configPlugins = plugins: (let
      pluginName = p: if lib.types.package.check p then p.pname else p.plugin.pname;
      pluginRTP = p: if lib.types.package.check p then p.rtp else p.plugin.rtp;
    in
      if plugins == [] || ! (builtins.isList plugins) then "" else ''
        # ============ #
        # Load plugins #
        # ------------ #

        ${(lib.concatMapStringsSep "\n\n" (p: ''
          # ${pluginName p}
          # ---------------------
          ${p.extraConfig or ""}
          run-shell ${pluginRTP p}
        '') plugins)}
        # ============================================== #
      ''
    );

  tmux = pkgs.writeShellScriptBin "tmux" (/*bash*/''
    export TMUX_TMPDIR=''${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}
    exec ${pkgs.tmux}/bin/tmux source-file ${pkgs.writeText "tmux.conf" confText} \; $@
  '');

  # module code to include with root installs
  # config.security.wrappers = {
  #   utempter = {
  #     source = "${pkgs.libutempter}/lib/utempter/utempter";
  #     owner = "root";
  #     group = "utmp";
  #     setuid = false;
  #     setgid = true;
  #   };
  # };
in
{ inherit tx tmux; }
