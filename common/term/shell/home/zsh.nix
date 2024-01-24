{config, pkgs, self, lib, inputs, ... }:
{
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
    birdeeMods.zsh.enableTMUX = lib.mkOption {
      description = "zsh starts in TMUX";
      type = lib.types.bool;
      default = true;
    };
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
      '' + (if cfg.enableTMUX then ''
        [ -z "$TMUX" ] && which tmux &> /dev/null && if [ $(tmux has-sessions &> /dev/null) ]; then
          exec tmux attach
        else
          exec tmux
        fi
      '' else "");
    };
  });
}
