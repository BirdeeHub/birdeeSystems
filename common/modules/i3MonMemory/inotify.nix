{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, ... }: let

    i3luaMon = {
      appname
      , userJsonCache ? null
      , xrandrOthersSH
      , xrandrPrimarySH
      , pkgs
      , lib
      , writeShellScript
      , stdenv
      , ...
    }: let
      procPath = with pkgs; [ i3 xorg.xrandr gawk ];
      luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
      luaProg = stdenv.mkDerivation {
        name = "${appname}";
        src = ./.;
        buildPhase = ''
          source $stdenv/setup
          ${luaEnv}/bin/luac -o $out ./${appname}.lua
        '';
        meta = { mainProgram = "${appname}"; };
      };
      launcher = writeShellScript "${appname}" ''
        export PATH=${lib.makeBinPath procPath}
        ${luaEnv}/bin/lua ${luaProg} "${xrandrOthersSH}" "${xrandrPrimarySH}"''
            + (if userJsonCache == null then "" else '' "${userJsonCache}"'');
    in launcher;

    i3MonMemory = pkgs.callPackage i3luaMon {
        appname = "i3luaMon";
        inherit userJsonCache xrandrPrimarySH xrandrOthersSH;
    };

    i3notifyMon = (pkgs.writeShellScript "runi3xrandrMemory.sh" ''
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname ${triggerFile})"
        ${pkgs.inotify-tools}/bin/inotifywait -e close_write -m "$(${pkgs.coreutils}/bin/dirname ${triggerFile})" |
        while read -r directory events filename; do
            if [ "$filename" = "$(${pkgs.coreutils}/bin/basename ${triggerFile})" ]; then
                ${pkgs.bash}/bin/bash -c '${i3MonMemory}'
            fi
        done
    '');
in i3notifyMon
