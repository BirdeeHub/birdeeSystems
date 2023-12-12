{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeZsh.enable = pkgs.lib.mkEnableOption "birdeeZsh";
  };
  config = {
    programs.zsh = pkgs.lib.mkIf config.birdeeZsh.enable {
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
        eval "$(oh-my-posh init zsh --config ${self}/shell/atomic-emodipt.omp.json)"
      '';
    };
  };
}
