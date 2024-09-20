isHomeModule: { config, pkgs, self, inputs, lib, ... }: let
  cfg = config.birdeeMods.ranger;
in {
  _file = ./default.nix;
  options = {
    birdeeMods.ranger = with lib.types; {
      enable = lib.mkEnableOption "birdee's ranger";
      withoutDragon = lib.mkEnableOption "smaller ranger without x-dragon";
    };
  };
  config = lib.mkIf cfg.enable (let
    ranger = pkgs.stdenv.mkDerivation (let
      rifle = ''${pkgs.ranger}/bin/rifle'';
      ranger_commands = pkgs.writeText "nixRangerRC.conf" (let
        dragon = ''${pkgs.xdragon}/bin/dragon'';
      in (if cfg.withoutDragon then "" else ''
        map <C-Y> shell ${dragon} -a -x %p
        map y<C-Y> shell ${dragon} --all-compact -x %p
      '') + ''
        set mouse_enabled!
        map ps shell echo "$(xclip -o) ." | ${pkgs.findutils}/bin/xargs cp -r
      '');
      rangerBinScript = pkgs.writeScript "ranger" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.ranger}/bin/ranger --cmd='source ${ranger_commands}' "$@"
      '';
      ranger_desktop = pkgs.writeText "ranger.desktop" (/*desktop*/''
        [Desktop Entry]
        Type=Application
        Name=ranger
        Comment=Launches the ranger file manager
        Icon=utilities-terminal
        Terminal=false
        Exec=alacritty -e ranger
        Categories=ConsoleOnly;System;FileTools;FileManager
        MimeType=inode/directory;
        Keywords=File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python
      '');
    in {
      name = "ranger";
      builder = pkgs.writeText "builder.sh" (/*bash*/''
        source $stdenv/setup
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        cp ${rangerBinScript} $out/bin/ranger
        cp ${rifle} $out/bin/rifle
        cp ${ranger_desktop} $out/share/applications/ranger.desktop
      '');
    });
  in (if isHomeModule then {
    home.packages = with pkgs; [
      xclip
      findutils
      ranger
    ];
  } else {
    environment.systemPackages = with pkgs; [
      xclip
      findutils
      ranger
    ];
  }));
}
