{ config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.ranger = with lib.types; {
      enable = lib.mkEnableOption "birdee's ranger";
    };
  };
    # the files in this directory will not be sourced, they are there as an example
    # they are all the default values.
    # I am only just learning how to use ranger for the first time.
  config = lib.mkIf config.birdeeMods.ranger.enable (let
    cfg = config.birdeeMods.ranger;
    ranger = pkgs.writeShellScriptBin "ranger" (let
    in ''
      ${pkgs.ranger}/bin/ranger --cmd="map <C-Y> shell ${pkgs.xdragon}/bin/dragon -a -x %p" "$@"
    '');
  in {
    home.packages = with pkgs; [
      ranger
    ];
  });
}
