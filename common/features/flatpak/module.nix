{ inputs, moduleNamespace, ... }:
{
  flake.modules.nixos.flatpak =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.${moduleNamespace}.flatpak.enable = lib.mkEnableOption "birdee flatpak module";
      config.services.flatpak.enable = config.${moduleNamespace}.flatpak.enable;
    };
  flake.modules.homeManager.flatpak =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.${moduleNamespace}.flatpak.enable = lib.mkEnableOption "birdee flatpak module";
      config.home.sessionVariables.XDG_DATA_DIRS = lib.mkIf config.${moduleNamespace}.flatpak.enable "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
}
