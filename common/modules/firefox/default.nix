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
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
          wappalyzer
          bitwarden
          foxyproxy-standard
          web-archives
          user-agent-string-switcher
          tampermonkey
          unpaywall
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
