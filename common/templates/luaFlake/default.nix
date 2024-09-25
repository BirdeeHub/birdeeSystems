{ pkgs, inputs, mkLuaApp, APPNAME, ... }: let
  lua_packages = (lpkgs: with lpkgs; [
    luafilesystem
    cjson
    inspect
    http
    cqueues
    stdlib
  ]);
  lua_interpreter = pkgs.luajit;
  final_package = let
    lua_package = {
    lib
    , coreutils
    , findutils
    , gnumake
    , gnused
    , gnugrep
    , gawk
    , callPackage

    , APPNAME ? "REPLACE_ME"
    , lua_packages ? (_:[])
    , extraLuaPackages ? (_:[])
    , lua_interpreter
    , extraWrapperArgs ? []
    , ...
    }: let
      procPath = [
        coreutils
        findutils
        gnumake
        gnused
        gnugrep
        gawk
      ];
      libPath = [];
      built_package = mkLuaApp callPackage {
        inherit extraLuaPackages APPNAME lua_interpreter lua_packages;
        wrapperArgs = [
          ''--prefix PATH ';' ${lib.makeBinPath procPath}''
          ''--prefix LD_LIBRARY_PATH ';' ${lib.makeLibraryPath libPath}''
        ] ++ extraWrapperArgs;
        LUA_SRC = ./lua;
        CPATH_DIR = null;
      };
    in
    built_package;
  in
  pkgs.callPackage lua_package { inherit lua_packages lua_interpreter APPNAME; };
in
final_package
