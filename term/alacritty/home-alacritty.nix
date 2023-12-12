{config, pkgs, self, inputs, ... }: let
in{
  home.packages = let
    alakitty = pkgs.writeScriptBin "alacritty" ''
      #!/bin/sh
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${self}/term/alacritty/alacritty.yml "$@"
    '';
  in
  with pkgs; [
    alakitty
  ];
}
