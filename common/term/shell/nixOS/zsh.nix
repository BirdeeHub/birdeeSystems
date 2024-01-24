{config, pkgs, inputs, lib, self, ... }: {
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
        '' + (if cfg.enableTMUX then ''
          [ -z "$TMUX" ] && which tmux &> /dev/null && exec tmux
        '' else "");
        promptInit = ''
          eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
        '';
    };
  });
}
