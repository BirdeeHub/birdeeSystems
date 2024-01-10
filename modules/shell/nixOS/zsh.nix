{config, pkgs, inputs, lib, self, ... }: {
  options = {
    birdeeMods.zsh.enable = lib.mkEnableOption "birdeeZsh";
  };
  config = lib.mkIf config.birdeeMods.zsh.enable {
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
        '';
        promptInit = ''
          eval "$(oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
        '';
    };
  };
}
