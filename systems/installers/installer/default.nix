{ config, lib, pkgs, modulesPath, inputs, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ../installer.nix
  ];

  # boot.kernelModules = [ "wl" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # boot.kernelPackages = pkgs.linuxPackages_6_6;
  # nixpkgs.config.permittedInsecurePackages = [
  #   "broadcom-sta-6.30.223.271-63-6.6.156"
  # ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  nix.settings.show-trace = true;

  isoImage.contents = [ ];

  wrappers = {
    neovim.enable = true;
    neovim.settings.minimal = true;
    git.enable = true;
    xplr.enable = true;
    zsh.enable = true;
    zsh.asSystemDefault = true;
  };
  birdeeMods = {
    bash.enable = true;
  };

  fonts.packages = with pkgs; [
    openmoji-color
    noto-fonts-color-emoji
    nerd-fonts.fira-mono
    nerd-fonts.go-mono
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "GoMono Nerd Font Mono" ];
      sansSerif = [ "FiraCode Nerd Font Mono" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
      emoji = [ "OpenMoji Color" "OpenMoji" "Noto Color Emoji" ];
    };
  };
  fonts.fontDir.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;
  environment.systemPackages = with pkgs; [
    xsel
    ntfs3g
    findutils
    exfat
    clamav
    lynis
    exfatprogs
    _7zz
    lshw
    xclip
    # dislocker
  ];

}
