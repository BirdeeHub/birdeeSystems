inputs:
{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
  # we need to grab the final pacakge,
  # because pkgs now has the updated tmux in it, so theres no unupdated tmux to use
  # because we are importing these wrapper modules in overlays
  # (it could still be grabbed from pkgs.tmux.configuration.package)
  tmux = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.tmux.wrap {
    updateEnvironment = builtins.attrNames config.luaInfo.set_environment_variables;
  };
  starship = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.starship.wrap;
in
{
  _file = ./default.nix;
  key = ./default.nix;
  imports = [ wlib.wrapperModules.wezterm ];
  options.shellString = lib.mkOption {
    type = wlib.types.stringable;
    default = "${pkgs.zsh}/bin/zsh";
  };
  options.launcher = lib.mkOption {
    type = lib.types.nullOr wlib.types.stringable;
    default = null;
  };
  options.withLauncher = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.gpuFrontEnd = lib.mkOption {
    type = lib.types.enum [
      "OpenGL"
      "Software"
      "WebGpu"
    ];
    default = "OpenGL";
  };
  options.webgpu_power_preference = lib.mkOption {
    type = lib.types.enum [
      "HighPerformance"
      "LowPower"
    ];
    default = "LowPower";
  };
  options.webgpu_force_fallback_adapter = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.fontString = lib.mkOption {
    type = lib.types.str;
    default = "FiraMono Nerd Font";
  };
  options.fontPackage = lib.mkOption {
    type = lib.types.package;
    default = pkgs.nerd-fonts.fira-mono;
  };
  options.wrapZSH = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.ZDOTDIR = lib.mkOption {
    type = lib.types.nullOr wlib.types.stringable;
    default = pkgs.callPackage ./zdot { inherit starship; };
  };
  config."wezterm.lua".content = /* lua */ ''
    local cfgdir = require('nix-info').config_dir
    require('nix-info').config_dir = nil
    package.path = package.path .. ';' .. cfgdir .. '/?.lua;' .. cfgdir .. '/?/init.lua'
    package.cpath = package.cpath .. ';' .. cfgdir .. '/?.so'
    local wezterm = require 'wezterm'
    wezterm.config_dir = cfgdir
    return require 'init'
  '';
  config.luaInfo = {
    config_dir = ./.;
    set_environment_variables = lib.optionalAttrs config.wrapZSH { inherit (config) ZDOTDIR; };
    inherit (config) webgpu_power_preference webgpu_force_fallback_adapter;
    front_end = config.gpuFrontEnd;
    font_dirs = [ "${config.fontPackage}/share/fonts" ];
    font = lib.generators.mkLuaInline "wezterm.font(${builtins.toJSON config.fontString})";
    color_scheme_dirs = [ "${config.luaInfo.config_dir}/colors" ];
    default_prog =
      lib.optional (config.shellString != null) config.shellString
      ++ lib.optionals (config.shellString != null && config.withLauncher) [
        "-c"
        "exec ${if config.launcher == null then "${tmux}/bin/tx" else config.launcher}"
      ];
  };
  config.extraPackages = [ tmux ];
  config.runShell = [
    "declare -f __bp_install_after_session_init && source '${placeholder "out"}/etc/profile.d/wezterm.sh'"
  ];
}
