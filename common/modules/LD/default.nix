{ moduleNamespace, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.LD;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.LD = with lib.types; {
      enable = lib.mkEnableOption "LD stuff";
    };
  };
  config = lib.mkIf cfg.enable (let
  in {
    programs.nix-ld = {
      enable  = true;
      package = pkgs.nix-ld;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs here, NOT in environment.systemPackages.
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        fuse3
        gdk-pixbuf
        glib
        gtk3
        icu
        libGL
        libappindicator-gtk3
        libdrm
        libglvnd
        libnotify
        libpulseaudio
        libunwind
        libusb1
        libuuid
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        pango
        pipewire
        sqlite
        stdenv.cc.cc
        systemd
        vulkan-loader
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.libxkbfile
        xorg.libxshmfence
        zlib
      ];
    };
  });
}
