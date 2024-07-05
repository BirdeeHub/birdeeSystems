{config, pkgs, self, inputs, lib, ... }:
{
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
  };
  config = lib.mkIf config.birdeeMods.bash.enable (let
    cfg = config.birdeeMods.bash;
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --bash > $out
      '';
    };
  in {
    programs.bash = {
      enableVteIntegration = true;
      initExtra = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
        source ${fzfinit}
      '';
    };
  });
}
