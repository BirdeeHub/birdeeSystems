{
  lib,
  stdenv,
  callPackage,
  writeShellScriptBin,
  writeText,
  wezterm,
  zsh,
  nerdfonts,
  noNixModules ? false,
  extraPATH ? [ ],
  ...
}:
let

  tmuxImport = callPackage ../tmux {
    isAlacritty = false;
    inherit noNixModules;
    # avoids infinite recursion by only needing the names
    varnames = (builtins.attrNames passables.envVars);
  };
  tmuxf = tmuxImport.tmux;
  txf = tmuxImport.tx;

  newzdotdir = callPackage ../zdot { inherit noNixModules; };

  nerdpkg = nerdfonts.override {
    fonts = [
      "FiraMono"
      "Go-Mono"
    ];
  };

  extraBin = [ tmuxf ] ++ extraPATH;

  passables = {
    cfgdir = "${wezCFG}";
    fontDirs = [ "${nerdpkg}/share/fonts" ];
    shellString = [
      "${zsh}/bin/zsh"
    ] ++ (lib.optionals (txf != null) [
      "-c"
      "exec ${txf}/bin/tx"
    ]);
    inherit noNixModules extraBin;
    envVars = {
      ZDOTDIR = "${newzdotdir}";
    };
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
