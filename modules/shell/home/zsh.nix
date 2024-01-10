{config, pkgs, self, lib, inputs, ... }:
{
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf config.birdeeMods.zsh.enable {
    programs.zsh = {
      shellAliases = {};
      enable = true;
      enableAutosuggestions = true;
      completionInit = (builtins.readFile ../compinstallOut);
      history.ignoreAllDups = true;
      initExtra = ''
        # Lines configured by zsh-newuser-install
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=10000
        setopt extendedglob
        unsetopt autocd nomatch
        bindkey -v
        # End of lines configured by zsh-newuser-install
        eval "$(oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  };
}
