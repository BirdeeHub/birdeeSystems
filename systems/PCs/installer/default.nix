{ config, lib, pkgs, system-modules, ... }: {
  imports = with system-modules; [
    birdeeVim.module
  ];

  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

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
