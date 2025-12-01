{
  lib,
  writeText,
  zsh,
  fzf,
  zsh-autosuggestions,
  zsh-vi-mode,
  starship,
  runCommand
}:
let
  newzshrc = writeText "zshrc" # bash
    ''
      [[ -f ~/.zshrc ]] && source "$HOME/.zshrc"

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
      source ${runCommand "fzfinit" {} "${fzf}/bin/fzf --zsh > $out"}
      . ${starship.wrap { addFlag = [ "init" "zsh" ]; }}/bin/starship
    '';
  newzshenv = ''[[ -f ~/.zshenv ]] && source "$HOME/.zshenv"'';
  newzprofile = ''[[ -f ~/.zprofile ]] && source "$HOME/.zprofile"'';
  newzlogin = ''[[ -f ~/.zlogin ]] && source "$HOME/.zlogin"'';
  newzlogout = ''[[ -f ~/.zlogout ]] && source "$HOME/.zlogout"'';
in
runCommand "newzdotdir" {} ''
  mkdir -p $out
  cp ${newzshrc} $out/.zshrc
  echo ${lib.escapeShellArg newzshenv} > $out/.zshenv
  echo ${lib.escapeShellArg newzprofile} > $out/.zprofile
  echo ${lib.escapeShellArg newzlogin} > $out/.zlogin
  echo ${lib.escapeShellArg newzlogout} > $out/.zlogout
''
