{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.zsh;
in {
  _file = ./zsh.nix;
  options = {
    ${moduleNamespace}.zsh = {
      enable = lib.mkEnableOption "birdeeZsh";
    };
  };
  config = lib.mkIf cfg.enable (let
    fzfinit = pkgs.runCommand "fzfinit" {} "${pkgs.fzf}/bin/fzf --zsh > $out";
    init = /*bash*/ ''
      . ${./compinstallOut}

      HISTFILE="$HOME/.zsh_history"
      HISTSIZE="10000"
      SAVEHIST="10000"
      setopt extendedglob hist_ignore_all_dups
      unsetopt autocd nomatch
      bindkey -v
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      source ${fzfinit}
    '';
    prompt = /* bash */ ''
      . ${config.wrapperModules.starship.wrap { shell = "zsh"; }}/bin/starship
    '';
  in if homeManager then {
    home.packages = [ pkgs.carapace ];
    programs.zsh = {
      shellAliases = {};
      enable = true;
      enableVteIntegration = true;
      initContent = /*bash*/''
      ${init}
      ${prompt}
      '';
    };
  } else {
    environment.systemPackages = [ pkgs.carapace ];
    programs.zsh = {
      enable = true;
      interactiveShellInit = init;
      promptInit = prompt;
    };
  });
}
