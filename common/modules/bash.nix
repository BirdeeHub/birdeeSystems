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
    fzfinit = pkgs.runCommand "fzfinit" {} "${pkgs.fzf}/bin/fzf --bash > $out";
    init = ''
      . ${config.wrapperModules.starship.wrap { shell = "bash"; }}/bin/starship
      export CARAPACE_BRIDGES='bash,inshellisense' # optional
      source <(${pkgs.carapace}/bin/carapace _carapace bash)
      source ${fzfinit}
    '';
  in if homeManager then {
    home.packages = [ pkgs.carapace ];
    programs.bash = {
      enableVteIntegration = true;
      initExtra = init;
    };
  } else {
    environment.systemPackages = [ pkgs.carapace ];
    programs.bash = {
      promptInit = init;
    };
  });
}
