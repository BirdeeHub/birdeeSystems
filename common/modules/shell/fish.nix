{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.fish;
in {
  _file = ./fish.nix;
  options = {
    ${moduleNamespace}.fish.enable = lib.mkEnableOption "birdeeFish";
  };
  config = lib.mkIf cfg.enable (let
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --fish > $out
      '';
    };
  in if homeManager then {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${./atomic-emodipt.omp.json} | source
        source ${fzfinit}
      '';
    };
  } else {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
      '';
      promptInit = ''
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${./atomic-emodipt.omp.json} | source
        source ${fzfinit}
      '';
    };
  });
}
