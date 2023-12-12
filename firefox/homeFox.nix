{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeFox.enable = pkgs.lib.mkEnableOption "birdeeFox";
  };
  config = {
  };
}
