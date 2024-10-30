with builtins; {
  writeShellScript
  , coreutils
  , SCRIPTNAME ? "backup_rotator"
  , MOST_RECENT ? "/backup/BACKUPDUMP.zip"
  , CACHEDIR ? "/backup/backupcache"
  , dumpAction ? (writeShellScript "dump" ''
      dest="$1"
      mkdir -p "$(dirname "$dest")"
      cp -r "$2" "$dest"
    '')
  , max ? 5
  , permissions ? { dir = 700; file = 600; }
  , ...
}:
writeShellScript SCRIPTNAME (let
  file_perms = toString permissions.file;
  dir_perms = toString permissions.dir;
in /*bash*/''
  export PATH="${coreutils}/bin:$PATH";
  umask 077
  MOST_RECENT='${MOST_RECENT}'
  CACHEDIR='${CACHEDIR}'
  cleanup() {
    [[ -d '${MOST_RECENT}' ]] && {
      chmod -R ${dir_perms} '${MOST_RECENT}'
      find '${MOST_RECENT}' -type f -exec chmod ${file_perms} {} \;
    }
    [[ -f '${MOST_RECENT}' ]] && chmod ${file_perms} '${MOST_RECENT}'
    [[ -e '${CACHEDIR}' ]] && {
      chmod -R ${dir_perms} '${CACHEDIR}'
      find '${CACHEDIR}' -type f -exec chmod ${file_perms} {} \;
    }
  }
  trap cleanup EXIT
  rotate_mv() {
    local file=$1 base=$2 zero=$3 num=$4
    max=${toString max}
    if [[ $num -gt $max ]]; then
      [[ $num -gt $zero ]] && rm -r "$file"
    elif [ -e "$base$num" ]; then
      rotate_mv "$base$num" "$base" "$zero" "$((num+1))"
      mv "$file" "$base$num"
    else
      mv "$file" "$base$num"
    fi
  }
  if [ -e "$MOST_RECENT" ]; then
    mkdir -p "$CACHEDIR"
    rotate_mv "$MOST_RECENT" "$CACHEDIR/$(basename "$MOST_RECENT")." 1 1
  fi
  ${dumpAction} "$MOST_RECENT" "$@"
'')
