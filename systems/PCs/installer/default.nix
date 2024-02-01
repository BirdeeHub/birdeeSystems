{ config, lib, pkgs, self, system-modules, inputs, disko, nixpkgs, ... }: {
  imports = with system-modules; [
    birdeeVim.module
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ../disko/sda.nix
  ];

  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  disko.enableConfig = false;

  environment.shellAliases = {
    install-birdeeOS = "${pkgs.writeShellScript "install-birdeeOS" ''
      sudo nix run github:nix-community/disko -- --mode disko --flake /iso/tmp/birdeeSystems#$1
      sudo nixos-install --flake /iso/tmp/birdeeSystems#$1
    ''}";
  };

  isoImage.contents = [
    { source = self; target = "/tmp/birdeeSystems";}
  ];

  birdeeVim = {
    enable = true;
    packageNames = [ "noAInvim" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
  environment.systemPackages = [ pkgs.git ];

}
