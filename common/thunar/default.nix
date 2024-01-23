{ config, pkgs, self, inputs, lib, ... }: {
  imports = [];
  options = {
    birdeeMods.thunar = {
      enable = lib.mkEnableOption "birdee's thunar config";
      plugins = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.package;
        description = lib.mdDoc "List of thunar plugins to install.";
        example = lib.literalExpression "with pkgs.xfce; [ thunar-archive-plugin thunar-volman ]";
      };
      enableCustomActions = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.thunar.enable (let
    cfg = config.birdeeMods.thunar;
    package = pkgs.xfce.thunar.override { thunarPlugins = cfg.plugins; };
  in {
    home.packages = [ package ];
    home.file = {
      ".config/Thunar/uca.xml".text = lib.mkIf cfg.enableCustomActions (builtins.readFile ./uca.xml);
    };
  });
}
