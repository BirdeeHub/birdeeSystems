{config, pkgs, self, inputs, lib, ... }: let
in {
  options = {
    birdeeMods.alacritty.enable = lib.mkEnableOption "alacritty";
  };
  config = lib.mkIf config.birdeeMods.alacritty.enable {
    home.packages = let
      alakitty = pkgs.writeScriptBin "alacritty" ''
        #!/bin/sh
        exec ${pkgs.alacritty}/bin/alacritty --config-file ${./alacritty.toml} "$@"
      '';
    in
    with pkgs; [
      alakitty
    ];
  };
}
