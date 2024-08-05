{
  lib,
  stdenv,
  callPackage,
  writeShellScriptBin,
  writeText,
  wezterm,
  zsh,
  nerdfonts,
  noNix ? false,
  extraPATH ? [ ],
  ...
}:
let

  tmuxImport = callPackage ./tmux.nix { isAlacritty = false; };
  tmuxf = tmuxImport.tmux;
  txf = tmuxImport.tx;

  newzdotdir = callPackage ./zdotdir.nix { inherit noNix; };

  fontpkg = nerdfonts.override {
    fonts = [
      "FiraMono"
      "Go-Mono"
    ];
  };

  extraBin = [ tmuxf ] ++ extraPATH;

  wztrmcfg = let
    passables = {
      cfgdir = "${wezCFG}";
      fontpkg = "${fontpkg}";
      shellString = [
        "${zsh}/bin/zsh"
      ] ++ (lib.optionals (txf != null)
        ["-c" "exec ${txf}/bin/tx"]
      );
      inherit noNix extraPATH;
      envVars = {
        TESTINGVAR = "test value";
        ZDOTDIR = "${newzdotdir}";
      };
    };
  in /*lua*/ ''
      package.preload["nixStuff"] = function()
        return ${(import ../../common/util).luaTablePrinter passables}
      end
      package.path = package.path .. ';' .. require('nixStuff').cfgdir .. '/?.lua;' .. require('nixStuff').cfgdir .. '/?/init.lua'
      package.cpath = package.cpath .. ';' .. require('nixStuff').cfgdir .. '/?.so'
      local wezterm = require 'wezterm'
      wezterm.config_dir = require('nixStuff').cfgdir
      wezterm.config_file = require('nixStuff').cfgdir .. "/wezterm.lua"
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
  # export ZDOTDIR="${newzdotdir}"
  exec ${wezterm}/bin/wezterm --config-file ${writeText "init.lua" wztrmcfg} $@
''
