{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeFox.enable = pkgs.lib.mkEnableOption "birdeeFox";
  };
  config = {
    programs.firefox = pkgs.lib.mkIf config.birdeeFox.enable (let
      nur-addons = inputs.nur.repos.rycee.firefox-addons;
    in {
      enable = true;
    });
  };
}
