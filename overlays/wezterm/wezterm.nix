{ lib, stdenv, callPackage, writeShellScriptBin, writeText, wezterm, zsh, nerdfonts, extraPATH ? [], ... }: let

  tmuxImport = callPackage ./tmux.nix { isAlacritty = false; };
  tmuxf = tmuxImport.tmux;
  txf = tmuxImport.tx;

  wezCFG = "${./.}";

  fontpkg = nerdfonts.override { fonts = [ "FiraMono" "Go-Mono" ]; };

  nixStuff = writeText "nixStuff.lua" ''
    return { cfgdir = [[${wezCFG}]], fontpkg = [[${fontpkg}]], shellString = [[${zsh}/bin/zsh]] }
  '';

  wztrmcfg = /*lua*/''
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
    config.font_size = 11.0
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
    config.default_prog = { shellString, "-l", ${if txf != null then ''"-c", "${txf}/bin/tx"'' else ""} }
    config.adjust_window_size_when_changing_font_size = nil
    config.use_fancy_tab_bar = false
    config.show_tabs_in_tab_bar = false
    config.tab_bar_at_bottom = false
    config.front_end = "Software"
    -- config.front_end = "OpenGL"
    -- config.front_end = "WebGpu"
    config.command_palette_rows = nil
    return config
  '';

in
writeShellScriptBin "wezterm" ''
  export PATH=${lib.makeBinPath ([ tmuxf ] ++ extraPATH)}:$PATH
  declare -f __bp_install_after_session_init && source "${wezterm}/etc/profile.d/wezterm.sh"
  exec ${wezterm}/bin/wezterm --config-file ${writeText "init.lua" wztrmcfg} $@
''
