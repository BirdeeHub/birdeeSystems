{config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.alacritty.enable = lib.mkEnableOption "alacritty";
  };
  config = lib.mkIf config.birdeeMods.alacritty.enable {
    environment.systemPackages = let
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
