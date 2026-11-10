{moduleNamespace, inputs, ...}: {
    flake.modules.nixos.theme = {pkgs, config, lib, ...}:
    let
      cfg = config.${moduleNamespace}.theme;
    in
    {
      _file = ./module.nix;
      options.${moduleNamespace}.theme = {
        enable = lib.mkEnableOption "power management dependencies";
      };
      config = lib.mkIf cfg.enable {
        qt.platformTheme = "gtk2";
        programs.dconf.enable = true;
        fonts.packages = with pkgs; [
          fira-code
          openmoji-color
          noto-fonts-color-emoji
          nerd-fonts.fira-mono
          nerd-fonts.go-mono
        ];
        fonts.fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "GoMono Nerd Font Mono" "FiraCode" ];
            sansSerif = [ "FiraCode Nerd Font Mono" "FiraCode" ];
            monospace = [ "FiraCode Nerd Font Mono"  "FiraCode" ];
            emoji = [ "OpenMoji Color" "OpenMoji" "Noto Color Emoji" ];
          };
        };
        fonts.fontDir.enable = true;
      };
    };
    flake.modules.homeManager.theme = {pkgs, config, lib, ...}:
    let
      cfg = config.${moduleNamespace}.theme;
    in
    {
      _file = ./module.nix;
      options.${moduleNamespace}.theme = {
        enable = lib.mkEnableOption "power management dependencies";
      };
      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          fira-code
          nerd-fonts.fira-mono
          open-fonts
          xkcd-font
          openmoji-color
          noto-fonts-color-emoji
          nerd-fonts.go-mono
        ];
        fonts.fontconfig.enable = true;

        home.pointerCursor.package = pkgs.phinger-cursors;
        home.pointerCursor.name = "phinger-cursors";
        home.pointerCursor.enable = true;
        home.pointerCursor.gtk.enable = true;
        home.pointerCursor.x11.enable = true;
        home.pointerCursor.x11.defaultCursor = "phinger-cursors";
        home.pointerCursor.dotIcons.enable = true;

        gtk.theme.package = pkgs.adw-gtk3;
        gtk.gtk4.theme = config.gtk.theme;
        gtk.theme.name = "adw-gtk3-dark";
        gtk.font.name = "Sans";
        gtk.font.size = 11;
        gtk.enable = true;

        qt.enable = true;
        qt.platformTheme.name = "gtk3";
        qt.style.package = pkgs.adwaita-qt;
        qt.style.name = "adwaita-qt";

        # gtk.gtk3.extraCss = '''';
        # gtk.gtk3.extraConfig = {};
        # gtk.gtk4.extraCss = '''';
        # gtk.gtk4.extraConfig = {};

        gtk.iconTheme.package = pkgs.beauty-line-icon-theme;
        gtk.iconTheme.name = "BeautyLine";
      };
    };
}
