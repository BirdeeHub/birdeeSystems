{ config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.ranger = with lib.types; {
      enable = lib.mkEnableOption "birdee's ranger";
    };
  };
  config = lib.mkIf config.birdeeMods.ranger.enable (let
    cfg = config.birdeeMods.ranger;
    ranger_commands = pkgs.writeText "nixRangerRC.conf" (let
      dragon = ''${pkgs.xdragon}/bin/dragon'';
      in ''
        map <C-Y> shell ${dragon} -a -x %p
        map y<C-Y> shell ${dragon} --all-compact -x %p
        set mouse_enabled!
        map ps shell echo "$(xclip -o) ." | xargs cp -r
      '');
    ranger = pkgs.writeShellScriptBin "ranger" (let
    in ''
      ${pkgs.ranger}/bin/ranger --cmd='source ${ranger_commands}' "$@"
    '');
  in {
    home.packages = with pkgs; [
      xsel
      xclip
      findutils
      ranger
    ];
  });
}
