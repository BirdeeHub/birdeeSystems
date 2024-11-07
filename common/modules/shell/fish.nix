{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.fish;
in {
  _file = ./fish.nix;
  options = {
    ${moduleNamespace}.fish = {
      enable = lib.mkEnableOption "birdeeFish";
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
        ${pkgs.fzf}/bin/fzf --fish > $out
      '';
    };
    themestr = if cfg.themer == "stars" then ''
        export STARSHIP_CONFIG='${./starship.toml}'
        ${pkgs.starship}/bin/starship init fish | source
    '' else ''
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${./atomic-emodipt.omp.json} | source
    '';
  in if homeManager then {
    home.packages = [ pkgs.carapace ];
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        ${themestr}
        export CARAPACE_BRIDGES='fish,inshellisense' # optional
        mkdir -p ~/.config/fish/completions
        ${pkgs.carapace}/bin/carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
        ${pkgs.carapace}/bin/carapace _carapace fish | source
        source ${fzfinit}
      '';
    };
  } else {
    environment.systemPackages = [ pkgs.carapace ];
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
      '';
      promptInit = ''
        ${themestr}
        export CARAPACE_BRIDGES='fish,inshellisense' # optional
        mkdir -p ~/.config/fish/completions
        ${pkgs.carapace}/bin/carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
        ${pkgs.carapace}/bin/carapace _carapace fish | source
        source ${fzfinit}
      '';
    };
  });
}
