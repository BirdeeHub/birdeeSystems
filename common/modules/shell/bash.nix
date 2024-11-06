{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.bash;
in {
  _file = ./bash.nix;
  options = {
    ${moduleNamespace}.bash = {
      enable = lib.mkEnableOption "birdeeBash";
      themer = lib.mkOption {
        default = "stars";
        type = lib.types.enum [ "stars" "OMP" ];
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --bash > $out
      '';
    };
    themestr = if cfg.themer == "stars" then ''
        export STARSHIP_CONFIG='${./starship.toml}'
        eval "$(${pkgs.starship}/bin/starship init bash)"
    '' else ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${./atomic-emodipt.omp.json})"
    '';
  in if homeManager then {
    programs.bash = {
      enableVteIntegration = true;
      initExtra = ''
        ${themestr}
        source ${fzfinit}
      '';
    };
  } else {
    programs.bash = {
      promptInit = ''
        ${themestr}
        source ${fzfinit}
      '';
    };
  });
}
