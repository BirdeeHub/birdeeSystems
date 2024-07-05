{config, pkgs, self, lib, inputs, ... }:
{
  options = {
    birdeeMods.fish.enable = lib.mkEnableOption "birdeeFish";
  };
  config = lib.mkIf config.birdeeMods.fish.enable (let
    cfg = config.birdeeMods.fish;
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --fish > $out
      '';
    };
  in {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${../atomic-emodipt.omp.json} | source
        source ${fzfinit}
      '';
    };
  });
}
