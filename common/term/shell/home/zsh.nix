{config, pkgs, self, lib, inputs, ... }:
{
  _file = ./zsh.nix;
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf config.birdeeMods.zsh.enable (let
    cfg = config.birdeeMods.zsh;
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
      completionInit = (builtins.readFile ../compinstallOut);
      initExtra = ''
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=10000
        setopt extendedglob hist_ignore_all_dups
        unsetopt autocd nomatch
        bindkey -v
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${fzfinit}
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}
