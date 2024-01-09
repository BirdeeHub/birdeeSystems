{config, pkgs, self, inputs, ... }: let
in{
  environment.systemPackages = let
    alakitty = pkgs.writeScriptBin "alacritty" ''
      #!/bin/sh
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${self}/term/alacritty/alacritty.toml "$@"
    '';
  in
  with pkgs; [
    alakitty
  ];
}
