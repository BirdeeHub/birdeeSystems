{ config, pkgs, self, inputs, stateVersion, users, hostname, system-modules, overlays, nixpkgs, ... }: let
in {
  imports = with system-modules; [
    ../PCs/aSUS
  ];
  config = {
  };
}
