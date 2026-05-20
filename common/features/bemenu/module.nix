{ inputs, ... }:
{
  flake.wrappers.bemenu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ ./. ];
      config.settings.prompt = "";
      config.constructFiles.clear-bemenu-recency = {
        relPath = "bin/bemenu-recency-clear";
        builder = ''mkdir -p "$(dirname "$2")" && cp "$1" "$2" && chmod +x "$2"'';
        content = /* bash */ ''
          #!${pkgs.bash}/bin/bash
          cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
          cache="$cachedir/bemenu_recent"
          rm $cache
        '';
      };
      config.constructFiles.bemenu-recency = {
        relPath = "bin/bemenu-recency";
        builder = ''mkdir -p "$(dirname "$2")" && cp "$1" "$2" && chmod +x "$2"'';
        content = /* bash */ ''
          #!${pkgs.bash}/bin/bash
          # bemenu_run - dmenu recency script adapted for bemenu
          # end a command with ; to run in a terminal
          term="${lib.getExe (inputs.self.wrappers.wezterm.wrap { inherit pkgs; })} -e"
          cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
          cache="$cachedir/bemenu_recent"

          touch "$cache"

          # cleaning
          while read cmd
          do
              command -v ''${cmd%;} &>/dev/null || sed -i "/$cmd/d" $cache
          done < <(sort -u $cache)

          most_used=$(sort "$cache" | uniq -c | sort -rh | sed 's/\s*//' | cut -d' ' -f2-)
          run=$( (echo "$most_used"; compgen -c | sort -u | grep -vxF "$most_used") | ${config.wrapperPaths.placeholder} -i "$@")

          [ -z "$run" ] && exit 1

          (echo "$run"; head -n 99 "$cache") > "$cache.$$"
          mv "$cache.$$" "$cache"

          case "$run" in
              *\;) exec $(echo "$term ''${run%;}") ;;
              *)   exec "$run" ;;
          esac
        '';
      };
    };
}
