{
  stdenv,
  writeText,
  zsh,
  fzf,
  zsh-autosuggestions,
  zsh-vi-mode,
  oh-my-posh,
}:
let
  fzfinit = stdenv.mkDerivation {
    name = "fzfinit";
    builder = writeText "builder.sh" # bash
      ''
        source $stdenv/setup
        ${fzf}/bin/fzf --zsh > $out
      '';
  };
  newzshrc = writeText "zshrc" # bash
    ''
      if [[ -f ~/.zshrc ]]; then
        source ~/.zshrc
      fi
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi

      typeset -U path cdpath fpath manpath

      for profile in ''${(z)NIX_PROFILES}; do
        fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
      done

      HELPDIR="${zsh}/share/zsh/$ZSH_VERSION/help"

      . ${./compinstallOut}

      HISTSIZE="10000"
      SAVEHIST="10000"

      HISTFILE="$HOME/.zsh_history"
      mkdir -p "$(dirname "$HISTFILE")"

      setopt HIST_FCNTL_LOCK
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt SHARE_HISTORY
      unsetopt EXTENDED_HISTORY
      setopt extendedglob
      unsetopt autocd nomatch
      bindkey -v
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      source ${fzfinit}
      eval "$(${oh-my-posh}/bin/oh-my-posh init zsh --config ${./atomic-emodipt.omp.json})"
    '';
  newzshenv = writeText "zshenv" /*bash*/''
    if [[ -f ~/.zshenv ]]; then
      source ~/.zshenv
    fi
  '';
  newzprofile = writeText "zprofile" /*bash*/''
    if [[ -f ~/.zprofile ]]; then
      source ~/.zprofile
    fi
  '';
  newzlogin = writeText "zlogin" /*bash*/''
    if [[ -f ~/.zlogin ]]; then
      source ~/.zlogin
    fi
  '';
  newzlogout = writeText "zlogout" /*bash*/''
    if [[ -f ~/.zlogout ]]; then
      source ~/.zlogout
    fi
  '';

in
stdenv.mkDerivation {
  name = "newzdotdir";
  builder = writeText "builder.sh" # bash
    ''
      source $stdenv/setup
      mkdir -p $out
      cp ${newzshrc} $out/.zshrc
      cp ${newzshenv} $out/.zshenv
      cp ${newzprofile} $out/.zprofile
      cp ${newzlogin} $out/.zlogin
      cp ${newzlogout} $out/.zlogout
    '';
}
