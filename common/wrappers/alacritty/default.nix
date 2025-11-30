{ config, pkgs, lib, wlib, ...}: {
  imports = [ wlib.wrapperModules.alacritty ];
  options.fontString = lib.mkOption {
    type = lib.types.str;
    default = "FiraMono Nerd Font";
  };
  options.tmuxPackage = lib.mkOption {
    type = lib.types.nullOr lib.types.package;
    default = null;
  };
  config.extraPackages = lib.mkIf (config.tmuxPackage != null) [ config.tmuxPackage ];
  config.settings.terminal.shell = {
    program = "${pkgs.zsh}/bin/zsh";
    args = [ "-l" ] ++ lib.optionals (config.tmuxPackage != null) [ "-c" "exec ${config.tmuxPackage}/bin/tx" ];
  };
  config.settings.font = {
    size = 11.0;
    normal = {
      family = config.fontString;
      style = "Regular";
    };
    bold = {
      family = config.fontString;
      style = "Bold";
    };
    bold_italic = {
      family = config.fontString;
      style = "Bold Italic";
    };
    italic = {
      family = config.fontString;
      style = "Italic";
    };
  };
}
