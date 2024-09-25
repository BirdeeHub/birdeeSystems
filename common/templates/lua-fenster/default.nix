{ pkgs, inputs, mkLuaApp, APPNAME, ... }: let
  buildFenster = lp: lp.buildLuarocksPackage {
    pname = "lua-fenster";
    version = "1.0.1-1";
    knownRockspec = "${inputs.lua-fenster}/fenster-dev-1.rockspec";
    src = inputs.lua-fenster;
    propagatedBuildInputs = [ pkgs.xorg.libX11 ];
    disabled = lp.luaOlder "5.1";
    meta = {
      homepage = "https://github.com/jonasgeiler/lua-fenster";
      description = "The most minimal cross-platform GUI library - now in Lua!";
      license.fullName = "MIT";
    };
  };
  lua_packages = (lpkgs: with lpkgs; [
    luafilesystem
    cjson
    busted
    inspect
    http
    cqueues
    stdlib
    (buildFenster lpkgs)
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
      };
    in
    built_package;
  in
  pkgs.callPackage lua_package { inherit lua_packages lua_interpreter APPNAME; };
in
final_package
