{config, pkgs, self, lib, inputs, ... }:
{
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf config.birdeeMods.zsh.enable (let
    cfg = config.birdeeMods.zsh;
  in {
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
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}

# function zle-line-init zle-keymap-select {
#     export ZSH_COMMAND_MODE=$KEYMAP
#     RPROMPT=%{$(tput cuu1)%}$KEYMAP
#     zle reset-prompt
# }
#
# zle -N zle-line-init
# zle -N zle-keymap-select
