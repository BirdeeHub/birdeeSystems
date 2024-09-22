{ moduleNamespace, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.firefox;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.firefox.enable = lib.mkEnableOption "birdeeFox";
  };
  config = lib.mkIf cfg.enable {
    programs.firefox = (let
    in {
      enable = true;
      profiles.birdee = {
        isDefault = true;
        name = "birdee";
        id = 0;
        extraConfig = builtins.readFile ./prefs.js;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          wappalyzer
          bitwarden
          search-by-image
          foxyproxy-standard
          web-archives
          user-agent-string-switcher
          tampermonkey
          unpaywall
          mullvad
          ninja-cookie
          ublock-origin
          languagetool
          maya-dark
          darkreader
        ];
      };
    });
  };
}
