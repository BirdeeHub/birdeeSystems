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
        libX11
        libXScrnSaver
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXtst
        libxcb
        libxkbfile
        libxshmfence
        zlib
      ];
    };
  });
}
