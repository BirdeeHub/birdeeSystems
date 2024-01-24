{ config, pkgs, self, inputs, lib, ... }: {
  imports = [
    (import ../xrandrMemoryi3 { home-manager = true;})
  ];
}
