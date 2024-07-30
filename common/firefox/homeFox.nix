{config, pkgs, self, inputs, lib, ... }:
{
  _file = ./homeFox.nix;
  options = {
    birdeeMods.firefox.enable = lib.mkEnableOption "birdeeFox";
  };
  config = lib.mkIf config.birdeeMods.firefox.enable {
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
