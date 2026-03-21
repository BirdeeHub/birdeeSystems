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
      cfg = config.${moduleNamespace}.fish;
      fzfinit = pkgs.runCommand "fzfinit" { } "${pkgs.fzf}/bin/fzf --fish > $out";
      init = ''
        fish_vi_key_bindings
      '';
      prompt = ''
        source ${config.wrappers.starship.wrap { shell = "fish"; }}/bin/starship
        export CARAPACE_BRIDGES='fish,inshellisense' # optional
        mkdir -p ~/.config/fish/completions
        ${pkgs.carapace}/bin/carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
        ${pkgs.carapace}/bin/carapace _carapace fish | source
        source ${fzfinit}
      '';
      options = {
        ${moduleNamespace}.fish = {
          enable = lib.mkEnableOption "birdeeFish";
        };
      };
      _file = ./fish.nix;
    in
    {
      homeManager = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.carapace ];
          programs.fish = {
            enable = true;
            interactiveShellInit = ''
              ${init}
              ${prompt}
            '';
          };
        };
      };
      nixos = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          environment.systemPackages = [ pkgs.carapace ];
          programs.fish = {
            enable = true;
            interactiveShellInit = init;
            promptInit = prompt;
          };
        };
      };
    }
    .${_class};
in
{
  flake.modules.nixos.fish = module;
  flake.modules.homeManager.fish = module;
}
