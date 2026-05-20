{ moduleNamespace, inputs, ... }:
let
  module =
    {
      config,
      pkgs,
      lib,
      _class,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.bash;
      _file = ./bash.nix;
      options = {
        ${moduleNamespace}.bash = {
          enable = lib.mkEnableOption "birdeeBash";
        };
      };
      fzfinit = pkgs.runCommand "fzfinit" { } "${pkgs.fzf}/bin/fzf --bash > $out";
      init = ''
        . ${config.wrappers.starship.wrap { shell = "bash"; }}/bin/starship
        export CARAPACE_BRIDGES='bash,inshellisense' # optional
        source <(${pkgs.carapace}/bin/carapace _carapace bash)
        source ${fzfinit}
      '';
    in
    {
      homeManager = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.carapace ];
          programs.bash = {
            enableVteIntegration = true;
            initExtra = init;
          };
        };
      };
      nixos = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          environment.systemPackages = [ pkgs.carapace ];
          programs.bash = {
            promptInit = init;
          };
        };
      };
    }
    .${_class};
in
{
  flake.modules.nixos.bash = module;
  flake.modules.homeManager.bash = module;
}
