{ pkgs, triggerFile, userJsonCache, xrandrPrimarySH, xrandrOthersSH, ... }: let
    luaEnv = "${ pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
      luafilesystem
      cjson
    ]) }/bin/lua";
    dependencies = {
      xrandr = pkgs.xorg.xrandr;
      i3-msg = pkgs.i3;
      awk = pkgs.gawk;
    };
    mkScriptAliases = with builtins; packageSet: concatStringsSep "\n" 
      ([ (/* lua */ "
        local paths = {}
      ") ] ++ (attrValues (mapAttrs (name: value: /* lua */ ''
            paths[ [[${name}]] ] = [[${value}/bin/${name}]]
      '') packageSet)));

    randrMemory = pkgs.writeScript "randrMemory.lua" (/* lua */''
        #!/usr/bin/env ${luaEnv}
        ${mkScriptAliases dependencies}
        local newmonConfig = [[${xrandrOthersSH}]]
        local alwaysRunConfig = [[${xrandrPrimarySH}]]
        local userJsonCache = [[${userJsonCache}]]
    '' + (builtins.readFile ./i3autoXrandrMemory.lua));

    i3notifyMon = (pkgs.writeShellScript "runi3xrandrMemory.sh" ''
        mkdir -p "$(dirname ${triggerFile})"
        ${pkgs.inotify-tools}/bin/inotifywait -e close_write -m "$(dirname ${triggerFile})" |
        while read -r directory events filename; do
            if [ "$filename" = "$(basename ${triggerFile})" ]; then
                ${pkgs.bash}/bin/bash -c '${randrMemory}'
            fi
        done
    '');
in i3notifyMon
