{ config, pkgs, self, inputs, lib, ... }: {
  imports = [];
  options = {
    birdeeMods.thunar = {
      enable = lib.mkEnableOptions "birdee's thunar config";
    };
  };
  config = lib.mkIf config.birdeeMods.thunar.enable (let
    cfg = config.birdeeMods.thunar;
  in {
    
  });
}
