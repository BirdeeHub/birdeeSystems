isHomeModule:
{config, pkgs, self, inputs, lib, ... }: let
in {
  options = {
    birdeeMods.alacritty = with lib.types; {
      enable = lib.mkEnableOption "alacritty";
      extraToml = lib.mkOption {
        default = "";
        type = str;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.alacritty.enable (let
    cfg = config.birdeeMods.alacritty;
    alacrittyToml = pkgs.writeText "alacritty.toml" (builtins.concatStringsSep "\n" [
      (import ./alacritty.nix { inherit config inputs pkgs self;})
      cfg.extraToml
      ]);
    alakitty = pkgs.writeScriptBin "alacritty" ''
      #!/bin/sh
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyToml} "$@"
    '';
  in (if isHomeModule then {
    home.packages = [ alakitty ];
  } else {
    environment.systemPackages = [ alakitty ];
  }));
}
