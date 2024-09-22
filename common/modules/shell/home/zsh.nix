{ moduleNamespace, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.zsh;
in {
  _file = ./zsh.nix;
  options = {
    ${moduleNamespace}.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf cfg.enable (let
    fzfinit = pkgs.stdenv.mkDerivation {
      name = "fzfinit";
      builder = pkgs.writeText "builder.sh" /* bash */ ''
        source $stdenv/setup
        ${pkgs.fzf}/bin/fzf --zsh > $out
      '';
    };
  in {
    programs.zsh = {
      shellAliases = {};
      enable = true;
      enableVteIntegration = true;
      initExtra = /*bash*/''
        . ${../compinstallOut}

        HISTFILE="$HOME/.zsh_history"
        HISTSIZE="10000"
        SAVEHIST="10000"
        setopt extendedglob hist_ignore_all_dups
        unsetopt autocd nomatch
        bindkey -v
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${fzfinit}
        # eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}
