{
  lib,
  stdenv,
  callPackage,
  writeShellScriptBin,
  writeText,
  wezterm,
  zsh,
  nerdfonts,
  fzf,
  zsh-autosuggestions,
  zsh-vi-mode,
  oh-my-posh,
  noNix ? false,
  extraPATH ? [ ],
  ...
}:
let

  tmuxImport = callPackage ./tmux.nix { isAlacritty = false; };
  tmuxf = tmuxImport.tmux;
  txf = tmuxImport.tx;

  wezCFG = "${./.}";

  newzdotdir = stdenv.mkDerivation (
    let
      fzfinit = stdenv.mkDerivation {
        name = "fzfinit";
        builder =
          writeText "builder.sh" # bash
            ''
              source $stdenv/setup
              ${fzf}/bin/fzf --zsh > $out
            '';
      };
      newzshrc =
        writeText "zshrc" # bash
          ''
            if ${if noNix then "true" else "false"}; then
              if [[ -f ~/.zshrc ]]; then
                source ~/.zshrc
              fi
              if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
                . "$HOME/.nix-profile/etc/profile.d/nix.sh"
              fi

              typeset -U path cdpath fpath manpath

              for profile in ''${(z)NIX_PROFILES}; do
                fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
              done

              HELPDIR="${zsh}/share/zsh/$ZSH_VERSION/help"

              . ${./compinstallOut}

              HISTSIZE="10000"
              SAVEHIST="10000"

              HISTFILE="$HOME/.zsh_history"
              mkdir -p "$(dirname "$HISTFILE")"

              setopt HIST_FCNTL_LOCK
              setopt HIST_IGNORE_DUPS
              setopt HIST_IGNORE_ALL_DUPS
              setopt HIST_IGNORE_SPACE
              setopt HIST_EXPIRE_DUPS_FIRST
              setopt SHARE_HISTORY
              unsetopt EXTENDED_HISTORY
              setopt extendedglob
              unsetopt autocd nomatch
              bindkey -v
              ZSH_AUTOSUGGEST_STRATEGY=(history completion)
              source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
              source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
              source ${fzfinit}
              eval "$(${oh-my-posh}/bin/oh-my-posh init zsh --config ${./atomic-emodipt.omp.json})"
              echo "test worked" > ~/testfileout
            fi
          '';
      newzshenv = writeText "zshenv" ''
        if [[ -f ~/.zshenv ]]; then
          source ~/.zshenv
        fi
      '';
      newzprofile = writeText "zprofile" ''
        if [[ -f ~/.zprofile ]]; then
          source ~/.zprofile
        fi
      '';
      newzlogin = writeText "zlogin" ''
        if [[ -f ~/.zlogin ]]; then
          source ~/.zlogin
        fi
      '';
      newzlogout = writeText "zlogout" ''
        if [[ -f ~/.zlogout ]]; then
          source ~/.zlogout
        fi
      '';
    in
    {
      name = "newzdotdir";
      builder =
        writeText "builder.sh" # bash
          ''
            source $stdenv/setup
            mkdir -p $out
            cp ${newzshrc} $out/.zshrc
            cp ${newzshenv} $out/.zshenv
            cp ${newzprofile} $out/.zprofile
            cp ${newzlogin} $out/.zlogin
            cp ${newzlogout} $out/.zlogout
          '';
    }
  );

  fontpkg = nerdfonts.override {
    fonts = [
      "FiraMono"
      "Go-Mono"
    ];
  };

  nixStuff = writeText "nixStuff.lua" ''
    return { cfgdir = [[${wezCFG}]], fontpkg = [[${fontpkg}]], shellString = [[${zsh}/bin/zsh]] }
  '';

  wztrmcfg = # lua
    ''
      -- See https://wezfurlong.org/wezterm/
      local fromnix = dofile('${nixStuff}')
      local wezCFG = fromnix.cfgdir
      local fontpkg = fromnix.fontpkg
      local shellString = fromnix.shellString
      local wezterm = require 'wezterm'
      local config = {}
      package.path = package.path .. ';' .. wezCFG .. '/?.lua;' .. wezCFG .. '/?/init.lua'
      wezterm.config_dir = wezCFG
      config.enable_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true
      config.font_size = 10.5
      config.color_scheme = 'Oceanic Next (Gogh)'
      config.font = wezterm.font('FiraMono Nerd Font')
      config.color_scheme_dirs = { wezCFG .. "/colors" }
      config.font_dirs = { fontpkg .. "/share/fonts" }
      config.keys = {}
      config.window_padding = {
        left = 0,
        right = -1,
        top = 0,
        bottom = -5,
      }
      config.default_prog = { shellString, "-l", ${ if txf != null then ''"-c", "${txf}/bin/tx"'' else "" } }
      config.adjust_window_size_when_changing_font_size = nil
      config.use_fancy_tab_bar = false
      config.show_tabs_in_tab_bar = false
      config.tab_bar_at_bottom = false
      config.front_end = "Software"
      -- config.front_end = "OpenGL"
      -- config.front_end = "WebGpu"
      config.command_palette_rows = 0
      return config
    '';

in
writeShellScriptBin "wezterm" ''
  export PATH="${lib.makeBinPath ([ tmuxf ] ++ extraPATH)}:$PATH"
  declare -f __bp_install_after_session_init && source '${wezterm}/etc/profile.d/wezterm.sh'
  export ZDOTDIR='${newzdotdir}'
  exec ${wezterm}/bin/wezterm --config-file ${writeText "init.lua" wztrmcfg} $@
''
