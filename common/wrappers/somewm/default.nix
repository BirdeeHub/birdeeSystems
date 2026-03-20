{ inputs, ... }:
{ config, pkgs, lib, wlib, ... }: {
  imports = [ ./module.nix ];
  config.package = inputs.somewm.packages.${pkgs.stdenv.hostPlatform.system}.default;
  config.init = ''
  '';
}
