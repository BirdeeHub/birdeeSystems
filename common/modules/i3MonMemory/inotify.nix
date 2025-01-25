{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, nixToLua, ... }: let

  i3luaMon = {
    appname
    , userJsonCache ? null
    , xrandrOthersSH
    , xrandrPrimarySH
    , lua5_2
    , writeScript
    , stdenv
    , ...
  }: let
    luaEnv = lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
    toPass = {
        json_cache = userJsonCache;
        always_run = xrandrPrimarySH;
        newmon = xrandrOthersSH;
    };
    luaProg = stdenv.mkDerivation {
      name = appname + ".lua";
      src = ./${appname}.lua;
      phases = [ "buildPhase" ];
      buildPhase = ''
        ${luaEnv}/bin/luac -o $out $src
      '';
    };
    launcher = writeScript appname /*lua*/''
      #!${luaEnv.interpreter}
      package.preload["nixinfo"] = function()
        return ${nixToLua.toLua toPass}
      end
      dofile(${nixToLua.toLua luaProg})
    '';
  in launcher;

  i3MonMemory = pkgs.callPackage i3luaMon {
    appname = "i3luaMon";
    inherit userJsonCache xrandrPrimarySH xrandrOthersSH;
  };

  luaProgPath = with pkgs; [ i3 xorg.xrandr gawk ];

  i3notifyMon = pkgs.writeShellScript "runi3xrandrMemory.sh" ''
    PATH="${pkgs.lib.makeBinPath (with pkgs; [ bash coreutils inotify-tools ])}"
    mkdir -p "$(dirname ${triggerFile})"
    inotifywait -e close_write -m "$(dirname ${triggerFile})" |
    while read -r directory events filename; do
      if [ "$filename" == "$(basename ${triggerFile})" ]; then
        bash -c 'PATH=${pkgs.lib.makeBinPath luaProgPath} ${i3MonMemory}'
      fi
    done
  '';
in i3notifyMon
