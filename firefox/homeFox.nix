{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeFox.enable = pkgs.lib.mkEnableOption "birdeeFox";
  };
  config = {
    programs.firefox = pkgs.lib.mkIf config.birdeeFox.enable (let
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
          tree-style-tab
          search-by-image
          foxyproxy-standard
          web-archives
          user-agent-string-switcher
          tampermonkey
          unpaywall
          one-click-wayback
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
