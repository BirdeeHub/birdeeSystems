{
  lib,
  stdenv,
  writeShellScriptBin,
  writeText,
  wezterm,
  zsh,
  nerdfonts,

  tmux,
  autotx ? true,
  custom_tmux_launcher_binsh ? null,
  zdotdir ? null,
  noNixModules ? false,
  extraPATH ? [ ],
  ...
}:
let

  nerdpkg = nerdfonts.override {
    fonts = [
      "FiraMono"
      "Go-Mono"
    ];
  };

  # avoids infinite recursion by only needing the names
  tmuxf = tmux.override { varnames = (builtins.attrNames passables.envVars); };

  tx = if custom_tmux_launcher_binsh != null then custom_tmux_launcher_binsh else writeShellScriptBin "tx" /*bash*/''
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

  extraBin = [ tmuxf tx ] ++ extraPATH;

  passables = {
    cfgdir = "${wezCFG}";
    fontDirs = [ "${nerdpkg}/share/fonts" ];
    shellString = [
      "${zsh}/bin/zsh"
    ] ++ (lib.optionals (tx != null && autotx) [
      "-c"
      "exec ${tx}/bin/tx"
    ]);
    inherit noNixModules extraBin;
    envVars = {
    } // (if noNixModules then {
      ZDOTDIR = "${zdotdir}";
    } else {});
  };

  wezinit = /*lua*/ ''
    package.preload["nixStuff"] = function()
      -- mini nixCats plugin
      return ${(import ./utils.nix).luaTablePrinter passables}
    end
    local cfgdir = require('nixStuff').cfgdir
    package.path = package.path .. ';' .. cfgdir .. '/?.lua;' .. cfgdir .. '/?/init.lua'
    package.cpath = package.cpath .. ';' .. cfgdir .. '/?.so'
    local wezterm = require 'wezterm'
    wezterm.config_dir = cfgdir
    wezterm.config_file = cfgdir .. "/init.lua"
    return require 'init'
  '';

  wezCFG = stdenv.mkDerivation {
    name = "weztermCFG";
    builder = writeText "builder.sh" /* bash */ ''
      source $stdenv/setup
      mkdir -p $out
      cp -r ${./.}/* $out/
    '';
  };

in
writeShellScriptBin "wezterm" ''
  export PATH="${lib.makeBinPath extraBin}:$PATH"
  declare -f __bp_install_after_session_init && source '${wezterm}/etc/profile.d/wezterm.sh'
  exec ${wezterm}/bin/wezterm --config-file ${writeText "init.lua" wezinit} $@
''
