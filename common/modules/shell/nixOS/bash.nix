{ moduleNamespace, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.bash;
in {
  _file = ./bash.nix;
  options = {
    ${moduleNamespace}.bash.enable = lib.mkEnableOption "birdeeBash";
  };
  config = lib.mkIf cfg.enable (let
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --bash > $out
      '';
    };
  in {
    programs.bash = {
      promptInit = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
        source ${fzfinit}
      '';
    };
  });
}
