{config, pkgs, inputs, lib, self, ... }: {
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
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${fzfinit}
      '';
      promptInit = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}
