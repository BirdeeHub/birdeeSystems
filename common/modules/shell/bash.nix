{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.bash;
in {
  _file = ./bash.nix;
  options = {
    ${moduleNamespace}.bash = {
      enable = lib.mkEnableOption "birdeeBash";
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
    themestr = ''eval "$(${pkgs.starship}/bin/starship init bash)"'';
  in if homeManager then {
    home.packages = [ pkgs.carapace ];
    programs.bash = {
      enableVteIntegration = true;
      initExtra = ''
        ${themestr}
        export CARAPACE_BRIDGES='bash,inshellisense' # optional
        source <(${pkgs.carapace}/bin/carapace _carapace bash)
        source ${fzfinit}
      '';
    };
  } else {
    environment.systemPackages = [ pkgs.carapace ];
    programs.bash = {
      promptInit = ''
        ${themestr}
        export CARAPACE_BRIDGES='bash,inshellisense' # optional
        source <(${pkgs.carapace}/bin/carapace _carapace bash)
        source ${fzfinit}
      '';
    };
  });
}
