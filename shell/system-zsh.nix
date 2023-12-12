{config, pkgs, inputs, self, ... }: {
  programs.zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
        strategy = [ "history" ];
      };
      interactiveShellInit = ''
        . ${self}/shell/compinstallOut

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
        eval "$(oh-my-posh init zsh --config ${self}/shell/atomic-emodipt.omp.json)"
      '';
  };
}
