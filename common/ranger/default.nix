{ config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.ranger = with lib.types; {
      enable = lib.mkEnableOption "birdee's ranger";
    };
  };
    # the files in this directory will not be sourced, they are there as an example
    # they are all the default values.
    # one day, I would like to source them via a command here.
  config = lib.mkIf config.birdeeMods.ranger.enable (let
    cfg = config.birdeeMods.ranger;
    ranger = pkgs.writeShellScriptBin "ranger" (let
    in ''
      ${pkgs.ranger}/bin/ranger --cmd="map <C-d> shell ${pkgs.xdragon}/bin/dragon -a -x %p" "$@"
    '');
  in {
    home.packages = with pkgs; [
      ranger
    ];
  });
}
