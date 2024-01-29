{config, pkgs, inputs, lib, self, ... }: {
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf config.birdeeMods.zsh.enable (let
    cfg = config.birdeeMods.zsh;
  in {
    programs.zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
        strategy = [ "history" ];
      };
      interactiveShellInit = ''
        . ${../compinstallOut}

        # Lines configured by zsh-newuser-install
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=10000
        setopt extendedglob
        unsetopt autocd nomatch
        bindkey -v
        # End of lines configured by zsh-newuser-install
        function zle-line-init zle-keymap-select {
            export ZSH_COMMAND_MODE=$KEYMAP
            RPROMPT=$ZSH_COMMAND_MODE
            zle reset-prompt
        }

        zle -N zle-line-init
        zle -N zle-keymap-select
      '';
      promptInit = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}
