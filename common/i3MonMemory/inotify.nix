{ pkgs, triggerFile, userJsonCache, xrandrPrimarySH, xrandrOthersSH, ... }: let
    mkLuaBang = luaEnv: "#!/usr/bin/env ${luaEnv}/bin/lua";
    luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
      luafilesystem
      cjson
    ]);
    dependencies = {
      xrandr = pkgs.xorg.xrandr;
      i3-msg = pkgs.i3;
      awk = pkgs.gawk;
    };
    mkScriptAliases = with builtins; packageSet: concatStringsSep "\n" 
      (["local nix_paths = {}"] ++ (attrValues (mapAttrs (name: value: ''
      nix_paths[ [[${name}]] ] = [[${value}/bin/${name}]]'') packageSet)));

    randrMemory = pkgs.writeScript "randrMemory.lua" (/* lua */''
        ${mkLuaBang luaEnv}
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
