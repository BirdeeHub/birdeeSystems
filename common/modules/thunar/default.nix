{ moduleNamespace, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.thunar;
in {
  _file = ./default.nix;
  imports = [];
  options = {
    ${moduleNamespace}.thunar = {
      enable = lib.mkEnableOption "birdee's thunar config";
      plugins = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.package;
        description = lib.mdDoc "List of thunar plugins to install.";
        example = lib.literalExpression "with pkgs.xfce; [ thunar-archive-plugin thunar-volman ]";
      };
      terminal = lib.mkOption {
        default = "${pkgs.wezterm}/bin/wezterm";
        type = lib.types.str;
      };
      enableCustomActions = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    package = pkgs.xfce.thunar.override { thunarPlugins = cfg.plugins; };
  in {
    home.packages = [ package ];
    home.file = {
      ".config/Thunar/uca.xml" = lib.mkIf cfg.enableCustomActions {
        force = true;
        text = /*xml*/ ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
          <action>
              <icon>utilities-terminal</icon>
              <name>Open Terminal Here</name>
              <submenu></submenu>
              <command>${cfg.terminal} --working-directory %f</command>
              <description></description>
              <range></range>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
          </action>
          </actions>
        '';
      };
    };
  });
}
